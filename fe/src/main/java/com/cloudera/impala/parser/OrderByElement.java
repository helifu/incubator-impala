// Copyright (c) 2011 Cloudera, Inc. All rights reserved.

package com.cloudera.impala.parser;


/**
 * Combination of expr and ASC/DESC.
 *
 */
class OrderByElement {
  private final Expr expr;
  private final boolean isAsc;

  public OrderByElement(Expr expr, boolean isAsc) {
    super();
    this.expr = expr;
    this.isAsc = isAsc;
  }

  public Expr getExpr() {
    return expr;
  }

  public boolean getIsAsc() {
    return isAsc;
  }
}
