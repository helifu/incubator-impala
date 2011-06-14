// Copyright (c) 2011 Cloudera, Inc. All rights reserved.

package com.cloudera.impala.parser;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

import com.cloudera.impala.catalog.PrimitiveType;
import com.cloudera.impala.common.AnalysisException;
import com.cloudera.impala.common.TreeNode;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.Lists;

/**
 * Root of the expr node hierarchy.
 *
 */
abstract public class Expr extends TreeNode<Expr> implements ParseNode, Cloneable {
  protected PrimitiveType type;  // result of analysis

  protected Expr() {
    super();
    type = PrimitiveType.INVALID_TYPE;
  }

  public PrimitiveType getType() {
    return type;
  }

  /* Perform semantic analysis of node and all of its children.
   * Throws exception if any errors found.
   * @see com.cloudera.impala.parser.ParseNode#analyze(com.cloudera.impala.parser.Analyzer)
   */
  public void analyze(Analyzer analyzer) throws AnalysisException {
    for (Expr child: children) {
      child.analyze(analyzer);
    }
  }

  /**
   * Helper function: analyze list of exprs
   * @param exprs
   * @param analyzer
   * @throws AnalysisException
   */
  public static void analyze(List<? extends Expr> exprs, Analyzer analyzer)
      throws AnalysisException {
    for (Expr expr: exprs) {
      expr.analyze(analyzer);
    }
  }

  public String toSql() {
    return "";
  }

  public String debugString() {
    return debugString(children);
  }

  public static String debugString(List<? extends Expr> exprs) {
    if (exprs == null || exprs.isEmpty()) {
      return "";
    }
    List<String> strings = Lists.newArrayList();
    for (Expr expr: exprs) {
      strings.add(expr.debugString());
    }
    return "(" + Joiner.on(" ").join(strings) + ")";
  }

  /* We use clone() instead of defining our own deepCopy() in order to take advantage
   * of having Java generate the field-by-field copy c'tors for the Expr subclasses.
   * @see java.lang.Object#clone()
   */
  @Override
  public Expr clone() {
    try {
      return (Expr) super.clone();
    } catch (CloneNotSupportedException e) {
      // all Expr subclasses should implement Cloneable
      Writer w = new StringWriter();
      PrintWriter pw = new PrintWriter(w);
      e.printStackTrace(pw);
      throw new UnsupportedOperationException(w.toString());
    }
  }

  @Override
  public boolean equals(Object obj) {
    if (obj == null) {
      return false;
    }
    if (obj.getClass() != this.getClass()) {
      return false;
    }
    // don't compare type, this could be called pre-analysis
    Expr expr = (Expr) obj;
    if (children.size() != expr.children.size()) {
      return false;
    }
    for (int i = 0; i < children.size(); ++i) {
      if (!children.get(i).equals(expr.children.get(i))) {
        return false;
      }
    }
    return true;
  }

  @Override
  public int hashCode() {
    throw new UnsupportedOperationException("Expr.hashCode() is not implemented");
  }

  /**
   * Map of expression substitutions (lhs[i] gets substituted with rhs[i]).
   *
   */
  static class SubstitutionMap {
    public ArrayList<Expr> lhs;  // left-hand side
    public ArrayList<Expr> rhs;  // right-hand side

    public SubstitutionMap() {
      this.lhs = Lists.newArrayList();
      this.rhs = Lists.newArrayList();
    }

    public String debugString() {
      Preconditions.checkState(lhs.size() == rhs.size());
      List<String> output = Lists.newArrayList();
      for (int i = 0; i < lhs.size(); ++i) {
        output.add(lhs.get(i).debugString() + ":" + rhs.get(i).debugString());
      }
      return "substmap(" + Joiner.on(" ").join(output) + ")";
    }
  }

  /**
   * Create a deep copy of 'this'. If substMap is non-null,
   * use it to substitute 'this' or its subnodes.
   * @param substMap
   * @return
   */
  public Expr clone(SubstitutionMap substMap) {
    if (substMap != null) {
      for (int i = 0; i < substMap.lhs.size(); ++i) {
        if (this.equals(substMap.lhs.get(i))) {
          return substMap.rhs.get(i).clone(null);
        }
      }
    }
    Expr result = (Expr) this.clone();
    result.children = Lists.newArrayList();
    for (Expr child: children) {
      result.children.add(((Expr) child).clone(substMap));
    }
    return result;
  }

  /**
   * Create a deep copy of 'l'. If substMap is non-null, use it to substitute the elements of l.
   * @param <C>
   * @param l
   * @param substMap
   * @return
   */
  public static <C extends Expr> ArrayList<C> cloneList(
      List<C> l, SubstitutionMap substMap) {
    Preconditions.checkNotNull(l);
    ArrayList<C> result = new ArrayList<C>();
    for (C element: l) {
      result.add((C) element.clone(substMap));
    }
    return result;
  }

  /**
   * Collect all Expr nodes of type 'cl' present in 'input'.
   * This can't go into TreeNode<>, because we'd be using the template param
   * NodeType.
   * @param <C>
   * @param input
   * @param cl
   * @param output
   */
  public static <C extends Expr> void collectList(
      List<? extends Expr> input, Class<C> cl, List<C> output) {
    Preconditions.checkNotNull(input);
    for (Expr e: input) {
      e.collect(cl, output);
    }
  }

  /**
   * Return true if the list contains a node of type C in any of
   * its elements or their children, otherwise return false.
   * @param input
   * @return
   */
  public static <C extends Expr> boolean contains(
      List<? extends Expr> input, Class<C> cl) {
    Preconditions.checkNotNull(input);
    for (Expr e: input) {
      if (e.contains(cl)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Return 'this' with all sub-exprs substituted according to
   * substMap.
   * @param substMap
   * @return
   */
  public Expr substitute(SubstitutionMap substMap) {
    Preconditions.checkNotNull(substMap);
    for (int i = 0; i < substMap.lhs.size(); ++i) {
      if (this.equals(substMap.lhs.get(i))) {
        return substMap.rhs.get(i).clone(null);
      }
    }
    for (int i = 0; i < children.size(); ++i) {
      children.set(i, ((Expr) children.get(i)).substitute(substMap));
    }
    return this;
  }

  /**
   * Substitute sub-exprs in the input list according to substMap.
   * @param <C>
   * @param l
   * @param substMap
   */
  public static <C extends Expr> void substituteList(
      List<C> l, SubstitutionMap substMap) {
    if (l == null) {
      return;
    }
    ListIterator<C> it = l.listIterator();
    while (it.hasNext()) {
      it.set((C) it.next().substitute(substMap));
    }
  }

  /**
   * Returns true if expr is fully bound by tid, otherwise false.
   */
  public boolean isBound(TupleId tid) {
    return isBound(Lists.newArrayList(tid));
  }

  /**
   * Returns true if expr is fully bound by tids, otherwise false.
   */
  public boolean isBound(List<TupleId> tids) {
    for (Expr child: children) {
      if (!child.isBound(tids)) {
        return false;
      }
    }
    return true;
  }

  public static boolean isBound(List<? extends Expr> exprs, List<TupleId> tids) {
    for (Expr expr: exprs) {
      if (!expr.isBound(tids)) {
        return false;
      }
    }
    return true;
  }
}
