// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#ifndef IMPALA_EXEC_KUDU_SCAN_NODE_BASE_H_
#define IMPALA_EXEC_KUDU_SCAN_NODE_BASE_H_

#include <gtest/gtest.h>
#include <kudu/client/client.h>

#include "exec/filter-context.h"
#include "exec/scan-node.h"
#include "runtime/descriptors.h"

namespace impala {

class KuduScanner;

/// Base class for the two Kudu scan node implementations. Contains the code that is
/// independent of whether the rows are materialized by scanner threads (KuduScanNode)
/// or by the thread calling GetNext (KuduScanNodeMt). This class is not thread safe
/// for concurrent access. Subclasses are responsible for implementing thread safety.
/// TODO: This class can be removed when the old single threaded implementation is
/// removed.
class KuduScanNodeBase : public ScanNode {
 public:
  KuduScanNodeBase(ObjectPool* pool, const TPlanNode& tnode, const DescriptorTbl& descs);
  ~KuduScanNodeBase();
  virtual Status Init(const TPlanNode& tnode, RuntimeState* state);
  virtual Status Prepare(RuntimeState* state);
  virtual Status Open(RuntimeState* state);
  virtual Status GetNext(RuntimeState* state, RowBatch* row_batch, bool* eos) = 0;
  virtual void Close(RuntimeState* state);

 protected:
  virtual void DebugString(int indentation_level, std::stringstream* out) const;

  /// Returns the total number of scan tokens
  int NumScanTokens() { return scan_tokens_.size(); }

  /// Returns whether there are any scan tokens remaining. Not thread safe.
  bool HasScanToken();

  /// Returns the next scan token. Returns NULL if there are no more scan tokens.
  /// Not thread safe, access must be synchronized.
  const std::string* GetNextScanToken();
  //Status TransformFilterToKuduBF(impala_kudu::BloomFiltersPB& kudu_bf);
  bool WaitForRuntimeFilters(int32_t time_ms);

  RuntimeState* runtime_state_;
  std::vector<FilterContext> filter_ctxs_;

  /// Set to true when the initial scan ranges are issued to the IoMgr. This happens on
  /// the first call to GetNext(). The token manager, in a different thread, will read
  /// this variable.
  bool initial_ranges_issued_;

  /// Waits for runtime filters if necessary.
  /// Only valid to call if !initial_ranges_issued_. Sets initial_ranges_issued_ to true.
  Status IssueRuntimeFilters(RuntimeState* state);

  /// Stops periodic counters and aggregates counter values for the entire scan node.
  /// This should be called as soon as the scan node is complete to get the most accurate
  /// counter values.
  /// This can be called multiple times, subsequent calls will be ignored.
  /// This must be called on Close() to unregister counters.
  /// Scan nodes with a RowBatch queue may have to synchronize calls to this function.
  void StopAndFinalizeCounters();

 private:
  friend class KuduScanner;

  /// Tuple id resolved in Prepare() to set tuple_desc_.
  const TupleId tuple_id_;

  /// Descriptor of tuples read from Kudu table.
  const TupleDescriptor* tuple_desc_;

  /// Pointer to the KuduClient, which is stored on the QueryState and shared between
  /// scanners and fragment instances.
  kudu::client::KuduClient* client_;

  /// Kudu table reference. Shared between scanner threads for KuduScanNode.
  kudu::client::sp::shared_ptr<kudu::client::KuduTable> table_;

  /// If true, counters are actively running and need to be reported in the runtime
  /// profile.
  bool counters_running_;

  /// Set of scan tokens to be deserialized into Kudu scanners.
  std::vector<std::string> scan_tokens_;

  /// The next index in 'scan_tokens_' to be assigned.
  int next_scan_token_idx_;

  RuntimeProfile::Counter* kudu_round_trips_;
  RuntimeProfile::Counter* kudu_remote_tokens_;
  static const std::string KUDU_ROUND_TRIPS;
  static const std::string KUDU_REMOTE_TOKENS;

  /// Returns a cloned copy of the scan node's conjuncts. Requires that the expressions
  /// have been open previously.
  Status GetConjunctCtxs(vector<ExprContext*>* ctxs);

  const TupleDescriptor* tuple_desc() const { return tuple_desc_; }
  kudu::client::KuduClient* kudu_client() { return client_; }
  RuntimeProfile::Counter* kudu_round_trips() const { return kudu_round_trips_; }
};

}

#endif
