#ifndef PATHFINDER_H
#define PATHFINDER_H

/* outsourced interface of the
 *       Pathfinder - Module
 */
static VALUE method_compile_to_sql  (VALUE self, VALUE query);
static VALUE method_compile_to_dot  (VALUE self, VALUE query);
static VALUE method_optimize        (int argc, VALUE* argv, VALUE self);

#endif
