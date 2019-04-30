# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Source this file from the $IMPALA_HOME directory to
# setup your environment. If $IMPALA_HOME is undefined
# this script will set it to the current working directory.
#
# Some config variables can be overridden. All overridable variables can be overridden
# by impala-config-branch.sh, which in turn can be by impala-config-local.sh. Some config
# variables in the second part of this file (e.g. locations of dependencies, secret keys)
# can be also overridden by setting environment variables before sourcing this file. We
# don't support this for variables that change between branches and versions, e.g.
# version numbers because it creates a "sticky config variable" problem where an old
# value stays in effect when switching between branches or rebasing until the developer
# opens a new shell. We also do not support overriding of some variables that are
# computed based on the values of other variables.
#
# This file must be kept compatible with bash options "set -euo pipefail". Those options
# will be set by other scripts before sourcing this file. Those options are not set in
# this script because scripts outside this repository may need to be updated and that
# is not practical at this time.

if ! [[ "'$IMPALA_HOME'" =~ [[:blank:]] ]]; then
  if [ -z "$IMPALA_HOME" ]; then
    if [[ ! -z "$ZSH_NAME" ]]; then
      export IMPALA_HOME=$(dirname "$(cd $(dirname ${(%):-%x}) >/dev/null && pwd)")
    else
      export IMPALA_HOME=$(dirname "$(cd $(dirname "${BASH_SOURCE[0]}") >/dev/null && pwd)")
    fi
  fi
fi

if [[ "'$IMPALA_HOME'" =~ [[:blank:]] ]]; then
  echo "IMPALA_HOME cannot have spaces in the path"
  exit 1
fi

export IMPALA_TOOLCHAIN=${IMPALA_TOOLCHAIN-"$IMPALA_HOME/toolchain"}
if [ -z "$IMPALA_TOOLCHAIN" ]; then
  echo "IMPALA_TOOLCHAIN must be specified. Please set it to a valid directory or"\
       "leave it unset."
  return 1
fi

#######################################################################################
# Variables that can be overridden by impala-config-*.sh but not by environment vars. #
# All component versions and other variables that get updated periodically or between #
# branches go here to avoid the "sticky variable" problem (IMPALA-4653) where the     #
# variable from a previously-sourced impala-config.sh overrides the new value.        #
#######################################################################################

# The unique build id of the toolchain to use if bootstrapping. This is generated by the
# native-toolchain build when publishing its build artifacts. This should be changed when
# moving to a different build of the toolchain, e.g. when a version is bumped or a
# compile option is changed. The build id can be found in the output of the toolchain
# build jobs, it is constructed from the build number and toolchain git hash prefix.
export IMPALA_TOOLCHAIN_BUILD_ID=24-3b615798c1
# Versions of toolchain dependencies.
# -----------------------------------
export IMPALA_AVRO_VERSION=1.7.4-p4
unset IMPALA_AVRO_URL
export IMPALA_BINUTILS_VERSION=2.26.1
unset IMPALA_BINUTILS_URL
export IMPALA_BOOST_VERSION=1.57.0-p3
unset IMPALA_BOOST_URL
export IMPALA_BREAKPAD_VERSION=97a98836768f8f0154f8f86e5e14c2bb7e74132e-p2
unset IMPALA_BREAKPAD_URL
export IMPALA_BZIP2_VERSION=1.0.6-p2
unset IMPALA_BZIP2_URL
export IMPALA_CCTZ_VERSION=2.2
unset IMPALA_CCTZ_URL
export IMPALA_CMAKE_VERSION=3.8.2-p1
unset IMPALA_CMAKE_URL
export IMPALA_CRCUTIL_VERSION=440ba7babeff77ffad992df3a10c767f184e946e-p1
unset IMPALA_CRCUTIL_URL
export IMPALA_CYRUS_SASL_VERSION=2.1.23
unset IMPALA_CYRUS_SASL_URL
export IMPALA_FLATBUFFERS_VERSION=1.6.0
unset IMPALA_FLATBUFFERS_URL
export IMPALA_GCC_VERSION=4.9.2
unset IMPALA_GCC_URL
export IMPALA_GDB_VERSION=7.9.1-p1
unset IMPALA_GDB_URL
export IMPALA_GFLAGS_VERSION=2.2.0-p2
unset IMPALA_GFLAGS_URL
export IMPALA_GLOG_VERSION=0.3.4-p3
unset IMPALA_GLOG_URL
export IMPALA_GPERFTOOLS_VERSION=2.5
unset IMPALA_GPERFTOOLS_URL
export IMPALA_GTEST_VERSION=1.6.0
unset IMPALA_GTEST_URL
export IMPALA_LIBEV_VERSION=4.20
unset IMPALA_LIBEV_URL
export IMPALA_LIBUNWIND_VERSION=1.3-rc1-p3
unset IMPALA_LIBUNWIND_URL
export IMPALA_LLVM_VERSION=5.0.1-p1
unset IMPALA_LLVM_URL
export IMPALA_LLVM_ASAN_VERSION=5.0.1-p1
unset IMPALA_LLVM_ASAN_URL

# Debug builds should use the release+asserts build to get additional coverage.
# Don't use the LLVM debug build because the binaries are too large to distribute.
export IMPALA_LLVM_DEBUG_VERSION=5.0.1-asserts-p1
unset IMPALA_LLVM_DEBUG_URL
export IMPALA_LZ4_VERSION=1.7.5
unset IMPALA_LZ4_URL
export IMPALA_OPENLDAP_VERSION=2.4.47
unset IMPALA_OPENLDAP_URL
export IMPALA_OPENSSL_VERSION=1.0.2l
unset IMPALA_OPENSSL_URL
export IMPALA_ORC_VERSION=1.5.5-p1
unset IMPALA_ORC_URL
export IMPALA_PROTOBUF_VERSION=3.5.1
unset IMPALA_PROTOBUF_URL
export IMPALA_POSTGRES_JDBC_DRIVER_VERSION=42.2.5
unset IMPALA_POSTGRES_JDBC_DRIVER_URL
export IMPALA_RAPIDJSON_VERSION=1.1.0
unset IMPALA_RAPIDJSON_URL
export IMPALA_RE2_VERSION=20190301
unset IMPALA_RE2_URL
export IMPALA_SNAPPY_VERSION=1.1.4
unset IMPALA_SNAPPY_URL
export IMPALA_SQUEASEL_VERSION=3.3
unset IMPALA_SQUEASEL_URL
# TPC utilities used for test/benchmark data generation.
export IMPALA_TPC_DS_VERSION=2.1.0
unset IMPALA_TPC_DS_URL
export IMPALA_TPC_H_VERSION=2.17.0
unset IMPALA_TPC_H_URL
export IMPALA_THRIFT_VERSION=0.9.3-p5
unset IMPALA_THRIFT_URL
export IMPALA_THRIFT11_VERSION=0.11.0-p2
unset IMPALA_THRIFT11_URL
export IMPALA_ZLIB_VERSION=1.2.8
unset IMPALA_ZLIB_URL

if [[ $OSTYPE == "darwin"* ]]; then
  IMPALA_CYRUS_SASL_VERSION=2.1.26
  unset IMPALA_CYRUS_SASL_URL
  IMPALA_GPERFTOOLS_VERSION=2.3
  unset IMPALA_GPERFTOOLS_URL
  IMPALA_OPENSSL_VERSION=1.0.1p
  unset IMPALA_OPENSSL_URL
fi

: ${IMPALA_TOOLCHAIN_HOST:=native-toolchain.s3.amazonaws.com}
export IMPALA_TOOLCHAIN_HOST
export CDH_MAJOR_VERSION=6
export CDH_BUILD_NUMBER=1046268
export CDP_BUILD_NUMBER=1013201
export IMPALA_HADOOP_VERSION=3.0.0-cdh6.x-SNAPSHOT
export IMPALA_HBASE_VERSION=2.1.0-cdh6.x-SNAPSHOT
export IMPALA_SENTRY_VERSION=2.1.0-cdh6.x-SNAPSHOT
export IMPALA_RANGER_VERSION=1.2.0.6.0.99.0-45
export IMPALA_PARQUET_VERSION=1.9.0-cdh6.x-SNAPSHOT
export IMPALA_AVRO_JAVA_VERSION=1.8.2-cdh6.x-SNAPSHOT
export IMPALA_LLAMA_MINIKDC_VERSION=1.0.0
export IMPALA_KITE_VERSION=1.0.0-cdh6.x-SNAPSHOT
export KUDU_JAVA_VERSION=1.10.0-cdh6.x-SNAPSHOT
export USE_CDP_HIVE=${USE_CDP_HIVE-false}
if $USE_CDP_HIVE; then
  export IMPALA_HIVE_VERSION=3.1.0.6.0.99.0-45
  # Temporary version of Tez, patched with the fix for TEZ-1348:
  # https://github.com/apache/tez/pull/40
  # We'll switch to a non-"todd" version of Tez once that fix is integrated.
  # For now, if you're bumping the CDP build number, you'll need to download
  # this tarball from an earlier build and re-upload it to the new directory
  # in the toolchain bucket.
  #
  # TODO(todd) switch to an official build.
  export IMPALA_TEZ_VERSION=0.10.0-todd-6fcc41e5798b.1
  export TEZ_HOME="$CDP_COMPONENTS_HOME/tez-${IMPALA_TEZ_VERSION}-minimal"
else
  export IMPALA_HIVE_VERSION=2.1.1-cdh6.x-SNAPSHOT
fi

# When IMPALA_(CDH_COMPONENT)_URL are overridden, they may contain '$(platform_label)'
# which will be substituted for the CDH platform label in bootstrap_toolchain.py
unset IMPALA_HADOOP_URL
unset IMPALA_HBASE_URL
unset IMPALA_HIVE_URL
unset IMPALA_KUDU_URL
unset IMPALA_KUDU_VERSION
unset IMPALA_SENTRY_URL
unset IMPALA_LLAMA_MINIKDC_URL

# Source the branch and local config override files here to override any
# variables above or any variables below that allow overriding via environment
# variable.
. "$IMPALA_HOME/bin/impala-config-branch.sh"
if [ -f "$IMPALA_HOME/bin/impala-config-local.sh" ]; then
  . "$IMPALA_HOME/bin/impala-config-local.sh"
fi

# It is important to have a coherent view of the JAVA_HOME and JAVA executable.
# The JAVA_HOME should be determined first, then the JAVA executable should be
# derived from JAVA_HOME. bin/bootstrap_development.sh adds code to
# bin/impala-config-local.sh to set JAVA_HOME, so it is important to pick up that
# setting before deciding what JAVA_HOME to use.

# Try to detect the system's JAVA_HOME
# If javac exists, then the system has a Java SDK (JRE does not have javac).
# Follow the symbolic links and use this to determine the system's JAVA_HOME.
SYSTEM_JAVA_HOME="/usr/java/default"
if [ -n "$(which javac)" ]; then
  SYSTEM_JAVA_HOME=$(which javac | xargs readlink -f | sed "s:/bin/javac::")
fi

# Prefer the JAVA_HOME set in the environment, but use the system's JAVA_HOME otherwise
export JAVA_HOME="${JAVA_HOME:-${SYSTEM_JAVA_HOME}}"
if [ ! -d "$JAVA_HOME" ]; then
  echo "JAVA_HOME must be set to the location of your JDK!"
  return 1
fi
export JAVA="$JAVA_HOME/bin/java"
if [[ ! -e "$JAVA" ]]; then
  echo "Could not find java binary at $JAVA" >&2
  return 1
fi

#########################################################################################
# Below here are variables that can be overridden by impala-config-*.sh and environment #
# vars, variables computed based on other variables, and variables that cannot be       #
# overridden.                                                                           #
#########################################################################################

# If true, will not call $IMPALA_HOME/bin/bootstrap_toolchain.py.
export SKIP_TOOLCHAIN_BOOTSTRAP=${SKIP_TOOLCHAIN_BOOTSTRAP-false}

# This flag is used in $IMPALA_HOME/cmake_modules/toolchain.cmake.
# If it's 0, Impala will be built with the compiler in the toolchain directory.
export USE_SYSTEM_GCC=${USE_SYSTEM_GCC-0}

# Use ld.gold instead of ld by default to speed up builds.
export USE_GOLD_LINKER=${USE_GOLD_LINKER-true}

# Override the default compiler by setting a path to the new compiler. The default
# compiler depends on USE_SYSTEM_GCC and IMPALA_GCC_VERSION. The intended use case
# is to set the compiler to distcc, in that case the user would also set
# IMPALA_BUILD_THREADS to increase parallelism.
export IMPALA_CXX_COMPILER=${IMPALA_CXX_COMPILER-default}

# Add options to 'mvn'; useful for configuring a settings file (-s).
export IMPALA_MAVEN_OPTIONS=${IMPALA_MAVEN_OPTIONS-}

# If enabled, debug symbols are added to cross-compiled IR.
export ENABLE_IMPALA_IR_DEBUG_INFO=${ENABLE_IMPALA_IR_DEBUG_INFO-false}

# Download and use the CDH components from S3. It can be useful to set this to false if
# building against a custom local build using HIVE_SRC_DIR_OVERRIDE,
# HADOOP_INCLUDE_DIR_OVERRIDE, and HADOOP_LIB_DIR_OVERRIDE.
export DOWNLOAD_CDH_COMPONENTS=${DOWNLOAD_CDH_COMPONENTS-true}

export IS_OSX="$(if [[ "$OSTYPE" == "darwin"* ]]; then echo true; else echo false; fi)"

export HADOOP_LZO="${HADOOP_LZO-$IMPALA_HOME/../hadoop-lzo}"
export IMPALA_LZO="${IMPALA_LZO-$IMPALA_HOME/../Impala-lzo}"
export IMPALA_AUX_TEST_HOME="${IMPALA_AUX_TEST_HOME-$IMPALA_HOME/../Impala-auxiliary-tests}"
export TARGET_FILESYSTEM="${TARGET_FILESYSTEM-hdfs}"
export ERASURE_CODING="${ERASURE_CODING-false}"
export FILESYSTEM_PREFIX="${FILESYSTEM_PREFIX-}"
export S3_BUCKET="${S3_BUCKET-}"
export azure_tenant_id="${azure_tenant_id-DummyAdlsTenantId}"
export azure_client_id="${azure_client_id-DummyAdlsClientId}"
export azure_client_secret="${azure_client_secret-DummyAdlsClientSecret}"
export azure_data_lake_store_name="${azure_data_lake_store_name-}"
export azure_storage_account_name="${azure_storage_account_name-}"
export azure_storage_container_name="${azure_storage_container_name-}"
export HDFS_REPLICATION="${HDFS_REPLICATION-3}"
export ISILON_NAMENODE="${ISILON_NAMENODE-}"
# Internal and external interfaces that test cluster services will listen on. The
# internal interface is used for ports that should not be accessed from outside the
# host that the cluster is running on. The external interface is used for ports
# that may need to be accessed from outside, e.g. web UIs.
export INTERNAL_LISTEN_HOST="${INTERNAL_LISTEN_HOST-localhost}"
export EXTERNAL_LISTEN_HOST="${EXTERNAL_LISTEN_HOST-0.0.0.0}"
export DEFAULT_FS="${DEFAULT_FS-hdfs://${INTERNAL_LISTEN_HOST}:20500}"
export WAREHOUSE_LOCATION_PREFIX="${WAREHOUSE_LOCATION_PREFIX-}"
export LOCAL_FS="file:${WAREHOUSE_LOCATION_PREFIX}"
ESCAPED_IMPALA_HOME=$(sed "s/[^0-9a-zA-Z]/_/g" <<< "$IMPALA_HOME")
if $USE_CDP_HIVE; then
  # It is likely that devs will want to with both the versions of metastore
  # if cdp hive is being used change the metastore db name, so we don't have to
  # format the metastore db everytime we switch between hive versions
  export METASTORE_DB=${METASTORE_DB-"$(cut -c-59 <<< HMS$ESCAPED_IMPALA_HOME)_cdp"}
else
  export METASTORE_DB=${METASTORE_DB-$(cut -c-63 <<< HMS$ESCAPED_IMPALA_HOME)}
fi


export SENTRY_POLICY_DB=${SENTRY_POLICY_DB-$(cut -c-63 <<< SP$ESCAPED_IMPALA_HOME)}
if [[ "${TARGET_FILESYSTEM}" == "s3" ]]; then
    # On S3, disable Sentry HDFS sync plugin.
    export SENTRY_PROCESSOR_FACTORIES="org.apache.sentry.api.service.thrift.SentryPolicyStoreProcessorFactory"
else
    export SENTRY_PROCESSOR_FACTORIES="org.apache.sentry.api.service.thrift.SentryPolicyStoreProcessorFactory,org.apache.sentry.hdfs.SentryHDFSServiceProcessorFactory"
fi
RANGER_POLICY_DB=${RANGER_POLICY_DB-$(cut -c-63 <<< ranger$ESCAPED_IMPALA_HOME)}
# The DB script in Ranger expects the database name to be in lower case.
export RANGER_POLICY_DB=$(echo ${RANGER_POLICY_DB} | tr '[:upper:]' '[:lower:]')

# Environment variables carrying AWS security credentials are prepared
# according to the following rules:
#
#     Instance:     Running outside EC2 ||  Running in EC2 |
# --------------------+--------+--------++--------+--------+
#   TARGET_FILESYSTEM |   S3   | not S3 ||   S3   | not S3 |
# --------------------+--------+--------++--------+--------+
#                     |        |        ||        |        |
#               empty | unset  | dummy  ||  unset |  unset |
# AWS_*               |        |        ||        |        |
# env   --------------+--------+--------++--------+--------+
# var                 |        |        ||        |        |
#           not empty | export | export || export | export |
#                     |        |        ||        |        |
# --------------------+--------+--------++--------+--------+
#
# Legend: unset:  the variable is unset
#         export: the variable is exported with its current value
#         dummy:  the variable is set to a constant dummy value and exported
#
# Running on an EC2 VM is indicated by setting RUNNING_IN_EC2 to "true" and
# exporting it from an script running before this one.

# Checks are performed in a subshell to avoid leaking secrets to log files.
if (set +x; [[ -n ${AWS_ACCESS_KEY_ID-} ]]); then
  export AWS_ACCESS_KEY_ID
else
  if [[ "${TARGET_FILESYSTEM}" == "s3" || "${RUNNING_IN_EC2:-false}" == "true" ]]; then
    unset AWS_ACCESS_KEY_ID
  else
    export AWS_ACCESS_KEY_ID=DummyAccessKeyId
  fi
fi

if (set +x; [[ -n ${AWS_SECRET_ACCESS_KEY-} ]]); then
  export AWS_SECRET_ACCESS_KEY
else
  if [[ "${TARGET_FILESYSTEM}" == "s3" || "${RUNNING_IN_EC2:-false}" == "true" ]]; then
    unset AWS_SECRET_ACCESS_KEY
  else
    export AWS_SECRET_ACCESS_KEY=DummySecretAccessKey
  fi
fi

# AWS_SESSION_TOKEN is not set to a dummy value, it is not needed by the FE tests
if (set +x; [[ -n ${AWS_SESSION_TOKEN-} ]]); then
  export AWS_SESSION_TOKEN
else
  unset AWS_SESSION_TOKEN
fi

if [ "${TARGET_FILESYSTEM}" = "s3" ]; then
  # We guard the S3 access check with a variable. This check hits a rate-limited endpoint
  # on AWS and multiple inclusions of S3 can exceed the limit, causing the check to fail.
  S3_ACCESS_VALIDATED="${S3_ACCESS_VALIDATED-0}"
  if [[ "${S3_ACCESS_VALIDATED}" -ne 1 ]]; then
    if ${IMPALA_HOME}/bin/check-s3-access.sh; then
      export S3_ACCESS_VALIDATED=1
      export DEFAULT_FS="s3a://${S3_BUCKET}"
    else
      return 1
    fi
  else
    echo "S3 access already validated"
  fi
elif [ "${TARGET_FILESYSTEM}" = "adls" ]; then
  # Basic error checking
  if [[ "${azure_client_id}" = "DummyAdlsClientId" ||\
        "${azure_tenant_id}" = "DummyAdlsTenantId" ||\
        "${azure_client_secret}" = "DummyAdlsClientSecret" ]]; then
    echo "All 3 of the following need to be assigned valid values and belong
      to the owner of the ADLS store in order to access the filesystem:
      azure_client_id, azure_tenant_id, azure_client_secret."
    return 1
  fi
  if [[ "${azure_data_lake_store_name}" = "" ]]; then
    echo "azure_data_lake_store_name cannot be an empty string for ADLS"
    return 1
  fi
  DEFAULT_FS="adl://${azure_data_lake_store_name}.azuredatalakestore.net"
  export DEFAULT_FS
elif [ "${TARGET_FILESYSTEM}" = "abfs" ]; then
  # ABFS is also known as ADLS Gen2, and they can share credentials
  # Basic error checking
  if [[ "${azure_client_id}" = "DummyAdlsClientId" ||\
        "${azure_tenant_id}" = "DummyAdlsTenantId" ||\
        "${azure_client_secret}" = "DummyAdlsClientSecret" ]]; then
    echo "All 3 of the following need to be assigned valid values and belong
      to the owner of the Azure storage account in order to access the
      filesystem: azure_client_id, azure_tenant_id, azure_client_secret."
    return 1
  fi
  if [[ "${azure_storage_account_name}" = "" ]]; then
    echo "azure_storage_account_name cannot be an empty string for ABFS"
    return 1
  fi
  if [[ "${azure_storage_container_name}" = "" ]]; then
    echo "azure_storage_container_name cannot be an empty string for ABFS"
    return 1
  fi
  domain="${azure_storage_account_name}.dfs.core.windows.net"
  DEFAULT_FS="abfss://${azure_storage_container_name}@${domain}"
  export DEFAULT_FS
elif [ "${TARGET_FILESYSTEM}" = "isilon" ]; then
  if [ "${ISILON_NAMENODE}" = "" ]; then
    echo "In order to access the Isilon filesystem, ISILON_NAMENODE"
    echo "needs to be a non-empty and valid address."
    return 1
  fi
  DEFAULT_FS="hdfs://${ISILON_NAMENODE}:8020"
  export DEFAULT_FS
  # isilon manages its own replication.
  export HDFS_REPLICATION=1
elif [ "${TARGET_FILESYSTEM}" = "local" ]; then
  if [[ "${WAREHOUSE_LOCATION_PREFIX}" = "" ]]; then
    echo "WAREHOUSE_LOCATION_PREFIX cannot be an empty string for local filesystem"
    return 1
  fi
  if [ ! -d "${WAREHOUSE_LOCATION_PREFIX}" ]; then
    echo "'$WAREHOUSE_LOCATION_PREFIX' is not a directory on the local filesystem."
    return 1
  elif [ ! -r "${WAREHOUSE_LOCATION_PREFIX}" ] || \
      [ ! -w "${WAREHOUSE_LOCATION_PREFIX}" ]; then
    echo "Current user does not have read/write permissions on local filesystem path "
        "'$WAREHOUSE_LOCATION_PREFIX'"
    return 1
  fi
  export DEFAULT_FS="${LOCAL_FS}"
  export FILESYSTEM_PREFIX="${LOCAL_FS}"
elif [ "${TARGET_FILESYSTEM}" = "hdfs" ]; then
  if [[ "${ERASURE_CODING}" = true ]]; then
    export HDFS_ERASURECODE_POLICY="RS-3-2-1024k"
    export HDFS_ERASURECODE_PATH="/test-warehouse"
  fi
else
  echo "Unsupported filesystem '$TARGET_FILESYSTEM'"
  echo "Valid values are: hdfs, isilon, s3, local"
  return 1
fi

# Directories where local cluster logs will go when running tests or loading data
DEFAULT_LOGS_DIR="${IMPALA_HOME}/logs"  # override by setting IMPALA_LOGS_DIR env var
export IMPALA_LOGS_DIR="${IMPALA_LOGS_DIR:-$DEFAULT_LOGS_DIR}"
export IMPALA_CLUSTER_LOGS_DIR="${IMPALA_LOGS_DIR}/cluster"
export IMPALA_DATA_LOADING_LOGS_DIR="${IMPALA_LOGS_DIR}/data_loading"
export IMPALA_DATA_LOADING_SQL_DIR="${IMPALA_DATA_LOADING_LOGS_DIR}/sql"
export IMPALA_FE_TEST_LOGS_DIR="${IMPALA_LOGS_DIR}/fe_tests"
export IMPALA_FE_TEST_COVERAGE_DIR="${IMPALA_FE_TEST_LOGS_DIR}/coverage"
export IMPALA_BE_TEST_LOGS_DIR="${IMPALA_LOGS_DIR}/be_tests"
export IMPALA_EE_TEST_LOGS_DIR="${IMPALA_LOGS_DIR}/ee_tests"
export IMPALA_CUSTOM_CLUSTER_TEST_LOGS_DIR="${IMPALA_LOGS_DIR}/custom_cluster_tests"
export IMPALA_MVN_LOGS_DIR="${IMPALA_LOGS_DIR}/mvn"
export IMPALA_TIMEOUT_LOGS_DIR="${IMPALA_LOGS_DIR}/timeout_stacktrace"
# List of all Impala log dirs so they can be created by buildall.sh
export IMPALA_ALL_LOGS_DIRS="${IMPALA_CLUSTER_LOGS_DIR}
  ${IMPALA_DATA_LOADING_LOGS_DIR} ${IMPALA_DATA_LOADING_SQL_DIR}
  ${IMPALA_FE_TEST_LOGS_DIR} ${IMPALA_FE_TEST_COVERAGE_DIR}
  ${IMPALA_BE_TEST_LOGS_DIR} ${IMPALA_EE_TEST_LOGS_DIR}
  ${IMPALA_CUSTOM_CLUSTER_TEST_LOGS_DIR} ${IMPALA_MVN_LOGS_DIR}
  ${IMPALA_TIMEOUT_LOGS_DIR}"

# Reduce the concurrency for local tests to half the number of cores in the system.
CORES=$(($(getconf _NPROCESSORS_ONLN) / 2))
export NUM_CONCURRENT_TESTS="${NUM_CONCURRENT_TESTS-${CORES}}"

export KUDU_MASTER_HOSTS="${KUDU_MASTER_HOSTS:-${INTERNAL_LISTEN_HOST}}"
export KUDU_MASTER_PORT="${KUDU_MASTER_PORT:-7051}"
export KUDU_MASTER_WEBUI_PORT="${KUDU_MASTER_WEBUI_PORT:-8051}"

export IMPALA_FE_DIR="$IMPALA_HOME/fe"
export IMPALA_BE_DIR="$IMPALA_HOME/be"
export IMPALA_WORKLOAD_DIR="$IMPALA_HOME/testdata/workloads"
export IMPALA_AUX_WORKLOAD_DIR="$IMPALA_AUX_TEST_HOME/testdata/workloads"
export IMPALA_DATASET_DIR="$IMPALA_HOME/testdata/datasets"
export IMPALA_AUX_DATASET_DIR="$IMPALA_AUX_TEST_HOME/testdata/datasets"
export IMPALA_COMMON_DIR="$IMPALA_HOME/common"
export PATH="$IMPALA_TOOLCHAIN/gdb-$IMPALA_GDB_VERSION/bin:$PATH"
export PATH="$IMPALA_HOME/bin:$IMPALA_TOOLCHAIN/cmake-$IMPALA_CMAKE_VERSION/bin/:$PATH"

# The directory in which all the thirdparty CDH components live.
export CDH_COMPONENTS_HOME="$IMPALA_TOOLCHAIN/cdh_components-$CDH_BUILD_NUMBER"

# The directory in which all the thirdparty CDP components live.
export CDP_COMPONENTS_HOME="$IMPALA_TOOLCHAIN/cdp_components-$CDP_BUILD_NUMBER"

# Typically we build against a snapshot build of Hadoop that includes everything we need
# for building Impala and running a minicluster.
export HADOOP_HOME="$CDH_COMPONENTS_HOME/hadoop-${IMPALA_HADOOP_VERSION}/"
export HADOOP_CONF_DIR="$IMPALA_FE_DIR/src/test/resources"
# The include and lib paths are needed to pick up hdfs.h and libhdfs.*
# Allow overriding in case we want to point to a package/install with a different layout.
export HADOOP_INCLUDE_DIR=${HADOOP_INCLUDE_DIR_OVERRIDE:-"${HADOOP_HOME}/include"}
export HADOOP_LIB_DIR=${HADOOP_LIB_DIR_OVERRIDE:-"${HADOOP_HOME}/lib"}

# Please note that the * is inside quotes, thus it won't get expanded by bash but
# by java, see "Understanding class path wildcards" at http://goo.gl/f0cfft
export HADOOP_CLASSPATH="${HADOOP_CLASSPATH-}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
# YARN is configured to use LZO so the LZO jar needs to be in the hadoop classpath.
export LZO_JAR_PATH="$HADOOP_LZO/build/hadoop-lzo-0.4.15.jar"
HADOOP_CLASSPATH+=":$LZO_JAR_PATH"

# Beware of adding entries from $HADOOP_HOME here, because they can change
# the order of the classpath, leading to configuration not showing up first.
HADOOP_CLASSPATH="$LZO_JAR_PATH"
# Add the path containing the hadoop-aws jar, which is required to access AWS from the
# minicluster.
HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"

export MINI_DFS_BASE_DATA_DIR="$IMPALA_HOME/cdh-${CDH_MAJOR_VERSION}-hdfs-data"
export PATH="$HADOOP_HOME/bin:$PATH"

export MINIKDC_HOME="$CDH_COMPONENTS_HOME/llama-minikdc-${IMPALA_LLAMA_MINIKDC_VERSION}"
export SENTRY_HOME="$CDH_COMPONENTS_HOME/sentry-${IMPALA_SENTRY_VERSION}"
export SENTRY_CONF_DIR="$IMPALA_HOME/fe/src/test/resources"

export RANGER_HOME="${CDP_COMPONENTS_HOME}/ranger-${IMPALA_RANGER_VERSION}-admin"
export RANGER_CONF_DIR="$IMPALA_HOME/fe/src/test/resources"

# Extract the first component of the hive version.
export IMPALA_HIVE_MAJOR_VERSION=$(echo "$IMPALA_HIVE_VERSION" | cut -d . -f 1)
if $USE_CDP_HIVE; then
  export HIVE_HOME="$CDP_COMPONENTS_HOME/apache-hive-${IMPALA_HIVE_VERSION}-bin"
else
  export HIVE_HOME="$CDH_COMPONENTS_HOME/hive-${IMPALA_HIVE_VERSION}/"
fi
export PATH="$HIVE_HOME/bin:$PATH"
# Allow overriding of Hive source location in case we want to build Impala without
# a complete Hive build.
export HIVE_SRC_DIR=${HIVE_SRC_DIR_OVERRIDE:-"${HIVE_HOME}/src"}
# To configure Hive logging, there's a hive-log4j2.properties[.template]
# file in fe/src/test/resources. To get it into the classpath earlier
# than the hive-log4j2.properties file included in some Hive jars,
# we must set HIVE_CONF_DIR. Additionally, on Hadoop 3, because of
# https://issues.apache.org/jira/browse/HADOOP-15019, when HIVE_CONF_DIR happens to equal
# HADOOP_CONF_DIR, it gets de-duped out of its pole position in the CLASSPATH variable,
# so we add an extra "./" into the path to avoid that. Use HADOOP_SHELL_SCRIPT_DEBUG=true
# to debug issues like this. Hive may log something like:
#       Logging initialized using configuration in file:.../fe/src/test/resources/hive-log4j2.properties
#
# To debug log4j2 loading issues, add to HADOOP_CLIENT_OPTS:
#   -Dorg.apache.logging.log4j.simplelog.StatusLogger.level=TRACE
#
# We use a unique -Dhive.log.file to distinguish the HiveMetaStore and HiveServer2 logs.
export HIVE_CONF_DIR="$IMPALA_FE_DIR/./src/test/resources"

# Hive looks for jar files in a single directory from HIVE_AUX_JARS_PATH plus
# any jars in AUX_CLASSPATH. (Or a list of jars in HIVE_AUX_JARS_PATH.)
# The Postgres JDBC driver is downloaded by maven when building the frontend.
# Export the location of Postgres JDBC driver so Sentry can pick it up.
export POSTGRES_JDBC_DRIVER="${IMPALA_FE_DIR}/target/dependency/postgresql-${IMPALA_POSTGRES_JDBC_DRIVER_VERSION}.jar"

export HIVE_AUX_JARS_PATH="$POSTGRES_JDBC_DRIVER"
export AUX_CLASSPATH="${LZO_JAR_PATH}"
### Tell hive not to use jline
export HADOOP_USER_CLASSPATH_FIRST=true

export HBASE_HOME="$CDH_COMPONENTS_HOME/hbase-${IMPALA_HBASE_VERSION}/"
export PATH="$HBASE_HOME/bin:$PATH"

# Add the jars so hive can create hbase tables.
export AUX_CLASSPATH="$AUX_CLASSPATH:$HBASE_HOME/lib/hbase-common-${IMPALA_HBASE_VERSION}.jar"
export AUX_CLASSPATH="$AUX_CLASSPATH:$HBASE_HOME/lib/hbase-client-${IMPALA_HBASE_VERSION}.jar"
export AUX_CLASSPATH="$AUX_CLASSPATH:$HBASE_HOME/lib/hbase-server-${IMPALA_HBASE_VERSION}.jar"
export AUX_CLASSPATH="$AUX_CLASSPATH:$HBASE_HOME/lib/hbase-protocol-${IMPALA_HBASE_VERSION}.jar"
export AUX_CLASSPATH="$AUX_CLASSPATH:$HBASE_HOME/lib/hbase-hadoop-compat-${IMPALA_HBASE_VERSION}.jar"

export HBASE_CONF_DIR="$IMPALA_FE_DIR/src/test/resources"

# To use a local build of Kudu, set KUDU_BUILD_DIR to the path Kudu was built in and
# set KUDU_CLIENT_DIR to the path KUDU was installed in.
# Example:
#   git clone https://github.com/cloudera/kudu.git
#   ...build 3rd party etc...
#   mkdir -p $KUDU_BUILD_DIR
#   cd $KUDU_BUILD_DIR
#   cmake <path to Kudu source dir>
#   make
#   DESTDIR=$KUDU_CLIENT_DIR make install
export KUDU_BUILD_DIR=${KUDU_BUILD_DIR-}
export KUDU_CLIENT_DIR=${KUDU_CLIENT_DIR-}
if [[ -n "$KUDU_BUILD_DIR" && -z "$KUDU_CLIENT_DIR" ]]; then
  echo When KUDU_BUILD_DIR is set KUDU_CLIENT_DIR must also be set. 1>&2
  return 1
fi
if [[ -z "$KUDU_BUILD_DIR" && -n "$KUDU_CLIENT_DIR" ]]; then
  echo When KUDU_CLIENT_DIR is set KUDU_BUILD_DIR must also be set. 1>&2
  return 1
fi

# Only applies to the minicluster Kudu (we always link against the libkudu_client for the
# overall build type) and does not apply when using a local Kudu build.
export USE_KUDU_DEBUG_BUILD=${USE_KUDU_DEBUG_BUILD-false}

# Kudu doesn't compile on some old Linux distros. KUDU_IS_SUPPORTED enables building Kudu
# into the backend. We prefer to pull Kudu in from CDH, but will fall back to using the
# toolchain Kudu for distros where the CDH tarballs are not provided by setting
# USE_CDH_KUDU to false.
# The frontend build is OS independent since it is Java.
export USE_CDH_KUDU=${USE_CDH_KUDU-true}
if [[ -z "${KUDU_IS_SUPPORTED-}" ]]; then
  if [[ -n "$KUDU_BUILD_DIR" ]]; then
    KUDU_IS_SUPPORTED=true
  else
    KUDU_IS_SUPPORTED=false
    USE_CDH_KUDU=false
    if ! $IS_OSX; then
      if ! which lsb_release &>/dev/null; then
        echo Unable to find the 'lsb_release' command. \
            Please ensure it is available in your PATH. 1>&2
        return 1
      fi
      DISTRO_VERSION="$(lsb_release -sir 2>&1)"
      if [[ $? -ne 0 ]]; then
        echo lsb_release command failed, output was: "$DISTRO_VERSION" 1>&2
        return 1
      fi
      # Remove spaces, trim minor versions, and convert to lowercase.
      DISTRO_VERSION="$(tr -d ' \n' <<< "$DISTRO_VERSION" | cut -d. -f1 | tr "A-Z" "a-z")"
      case "$DISTRO_VERSION" in
        centos6 | centos7 | debian8 | suselinux12 | suse12 | ubuntu16 | ubuntu18)
          USE_CDH_KUDU=true
          KUDU_IS_SUPPORTED=true;;
        ubuntu14 )
          USE_CDH_KUDU=false
          KUDU_IS_SUPPORTED=true;;
      esac
    fi
  fi
fi
export KUDU_IS_SUPPORTED

if $USE_CDH_KUDU; then
  export IMPALA_KUDU_VERSION=${IMPALA_KUDU_VERSION-"1.10.0-cdh6.x-SNAPSHOT"}
  export IMPALA_KUDU_HOME=${CDH_COMPONENTS_HOME}/kudu-$IMPALA_KUDU_VERSION
else
  export IMPALA_KUDU_VERSION=${IMPALA_KUDU_VERSION-"9ba901a"}
  export IMPALA_KUDU_HOME=${IMPALA_TOOLCHAIN}/kudu-$IMPALA_KUDU_VERSION
fi

# Set $THRIFT_HOME to the Thrift directory in toolchain.
export THRIFT_HOME="${IMPALA_TOOLCHAIN}/thrift-${IMPALA_THRIFT_VERSION}"

# ASAN needs a matching version of llvm-symbolizer to symbolize stack traces.
export ASAN_SYMBOLIZER_PATH="${IMPALA_TOOLCHAIN}/llvm-${IMPALA_LLVM_ASAN_VERSION}/bin/llvm-symbolizer"

export CLUSTER_DIR="${IMPALA_HOME}/testdata/cluster"

# The number of parallel build processes we should run at a time.
export IMPALA_BUILD_THREADS=${IMPALA_BUILD_THREADS-"$(nproc)"}

# Additional flags to pass to make or ninja.
export IMPALA_MAKE_FLAGS=${IMPALA_MAKE_FLAGS-}

# Some environments (like the packaging build) might not have $USER set.  Fix that here.
export USER="${USER-`id -un`}"

# Configure python path
. "$IMPALA_HOME/bin/set-pythonpath.sh"

# These arguments are, despite the name, passed to every JVM created
# by an impalad.
# - Enable JNI check
# When running hive UDFs, this check makes it unacceptably slow (over 100x)
# Enable if you suspect a JNI issue
# TODO: figure out how to turn this off only the stuff that can't run with it.
#LIBHDFS_OPTS="-Xcheck:jni -Xcheck:nabounds"
export LIBHDFS_OPTS="${LIBHDFS_OPTS:-} -Djava.library.path=${HADOOP_LIB_DIR}/native/"
LIBHDFS_OPTS+=" -XX:ErrorFile=${IMPALA_LOGS_DIR}/hs_err_pid%p.log"


# IMPALA-5080: Our use of PermGen space sometimes exceeds the default maximum while
# running tests that load UDF jars.
LIBHDFS_OPTS="${LIBHDFS_OPTS} -XX:MaxPermSize=128m"

export IMPALA_SNAPPY_PATH="${IMPALA_TOOLCHAIN}/snappy-${IMPALA_SNAPPY_VERSION}/lib"

export JAVA_LIBRARY_PATH="${IMPALA_SNAPPY_PATH}"

# So that the frontend tests and PlanService can pick up required libraries
LIB_JAVA=`find "${JAVA_HOME}/"   -name libjava.so | head -1`
LIB_JSIG=`find "${JAVA_HOME}/"   -name libjsig.so | head -1`
LIB_JVM=` find "${JAVA_HOME}/"   -name libjvm.so  | head -1`
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:`dirname ${LIB_JAVA}`:`dirname ${LIB_JSIG}`"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:`dirname ${LIB_JVM}`"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HADOOP_LIB_DIR}/native"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${IMPALA_SNAPPY_PATH}"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${IMPALA_LZO}/build"

if [ $USE_SYSTEM_GCC -eq 0 ]; then
  IMPALA_TOOLCHAIN_GCC_LIB="${IMPALA_TOOLCHAIN}/gcc-${IMPALA_GCC_VERSION}/lib64"
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${IMPALA_TOOLCHAIN_GCC_LIB}"
fi

export LD_PRELOAD="${LD_PRELOAD-}:${LIB_JSIG}"

export CLASSPATH="$IMPALA_FE_DIR/target/dependency:${CLASSPATH-}"
CLASSPATH="$IMPALA_FE_DIR/target/classes:$CLASSPATH"
CLASSPATH="$IMPALA_FE_DIR/src/test/resources:$CLASSPATH"
CLASSPATH="$LZO_JAR_PATH:$CLASSPATH"

# A marker in the environment to prove that we really did source this file
export IMPALA_CONFIG_SOURCED=1

echo "IMPALA_HOME             = $IMPALA_HOME"
echo "HADOOP_HOME             = $HADOOP_HOME"
echo "HADOOP_CONF_DIR         = $HADOOP_CONF_DIR"
echo "HADOOP_INCLUDE_DIR      = $HADOOP_INCLUDE_DIR"
echo "HADOOP_LIB_DIR          = $HADOOP_LIB_DIR"
echo "MINI_DFS_BASE_DATA_DIR  = $MINI_DFS_BASE_DATA_DIR"
echo "HIVE_HOME               = $HIVE_HOME"
echo "HIVE_CONF_DIR           = $HIVE_CONF_DIR"
echo "HIVE_SRC_DIR            = $HIVE_SRC_DIR"
echo "HBASE_HOME              = $HBASE_HOME"
echo "HBASE_CONF_DIR          = $HBASE_CONF_DIR"
echo "SENTRY_HOME             = $SENTRY_HOME"
echo "SENTRY_CONF_DIR         = $SENTRY_CONF_DIR"
echo "RANGER_HOME             = $RANGER_HOME"
echo "RANGER_CONF_DIR         = $RANGER_CONF_DIR "
echo "MINIKDC_HOME            = $MINIKDC_HOME"
echo "THRIFT_HOME             = $THRIFT_HOME"
echo "HADOOP_LZO              = $HADOOP_LZO"
echo "IMPALA_LZO              = $IMPALA_LZO"
echo "CLASSPATH               = $CLASSPATH"
echo "LIBHDFS_OPTS            = $LIBHDFS_OPTS"
echo "PYTHONPATH              = $PYTHONPATH"
echo "JAVA_HOME               = $JAVA_HOME"
echo "LD_LIBRARY_PATH         = $LD_LIBRARY_PATH"
echo "LD_PRELOAD              = $LD_PRELOAD"
echo "POSTGRES_JDBC_DRIVER    = $POSTGRES_JDBC_DRIVER"
echo "IMPALA_TOOLCHAIN        = $IMPALA_TOOLCHAIN"
echo "METASTORE_DB            = $METASTORE_DB"
echo "DOWNLOAD_CDH_COMPONENTS = $DOWNLOAD_CDH_COMPONENTS"
echo "IMPALA_MAVEN_OPTIONS    = $IMPALA_MAVEN_OPTIONS"
echo "IMPALA_TOOLCHAIN_HOST   = $IMPALA_TOOLCHAIN_HOST"
echo "CDH_BUILD_NUMBER        = $CDH_BUILD_NUMBER"
echo "CDH_COMPONENTS_HOME     = $CDH_COMPONENTS_HOME"
echo "CDP_BUILD_NUMBER        = $CDP_BUILD_NUMBER"
echo "CDP_COMPONENTS_HOME     = $CDP_COMPONENTS_HOME"
echo "IMPALA_HADOOP_VERSION   = $IMPALA_HADOOP_VERSION"
echo "IMPALA_HIVE_VERSION     = $IMPALA_HIVE_VERSION"
echo "IMPALA_HBASE_VERSION    = $IMPALA_HBASE_VERSION"
echo "IMPALA_SENTRY_VERSION   = $IMPALA_SENTRY_VERSION"
echo "IMPALA_KUDU_VERSION     = $IMPALA_KUDU_VERSION"
echo "IMPALA_RANGER_VERSION   = $IMPALA_RANGER_VERSION"

# Kerberos things.  If the cluster exists and is kerberized, source
# the required environment.  This is required for any hadoop tool to
# work.  Note that if impala-config.sh is sourced before the
# kerberized cluster is created, it will have to be sourced again
# *after* the cluster is created in order to pick up these settings.
export MINIKDC_ENV="${IMPALA_HOME}/testdata/bin/minikdc_env.sh"
if "${CLUSTER_DIR}/admin" is_kerberized; then
  . "${MINIKDC_ENV}"
  echo " *** This cluster is kerberized ***"
  echo "KRB5_KTNAME            = $KRB5_KTNAME"
  echo "KRB5_CONFIG            = $KRB5_CONFIG"
  echo "KRB5_TRACE             = $KRB5_TRACE"
  echo "HADOOP_OPTS            = $HADOOP_OPTS"
  echo " *** This cluster is kerberized ***"
else
  # If the cluster *isn't* kerberized, ensure that the environment isn't
  # polluted with kerberos items that might screw us up.  We go through
  # everything set in the minikdc environment and explicitly unset it.
  unset `grep export "${MINIKDC_ENV}" | sed "s/.*export \([^=]*\)=.*/\1/" \
      | sort | uniq`
fi

# Check for minimum required Java version
# Only issue Java version warning when running Java 7.
if $JAVA -version 2>&1 | grep -q 'java version "1.7'; then
  cat << EOF

WARNING: Your development environment is configured for Hadoop 3 and Java 7. Hadoop 3
requires at least Java 8. Your JAVA binary currently points to $JAVA
and reports the following version:

EOF
  $JAVA -version
  echo
fi
