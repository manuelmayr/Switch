#include <ruby.h>
#include <pf_ferry.h>
#if HAVE_SIGNAL_H
  #include <signal.h>
#endif


#include "pathfinder.h"
#include "extconf.h"


/* ------ Ruby Pathfinder ------*/

/* the pathfinder module */
VALUE rb_mPathfinder = Qnil;
/* exception raised when pathfinder fails */
VALUE rb_ePathfinderFailed = Qnil;

#if HAVE_SIGNAL_H
/**
 * This handler is called whenever we get a SIGSEGV.
 *
 * It will print out some informative message and then terminate the program.
 */
RETSIGTYPE
segfault_handler(int sig)
{
    (void)sig;
    rb_raise(rb_ePathfinderFailed,
             "Pathfinder failed with a segmentation fault");
}
#endif



/* main entry point for ruby */
void
Init_pathfinder(void)
{
#if HAVE_SIGNAL_H
  /* setup sementation fault signal handler */
  signal(SIGSEGV, segfault_handler);
#endif

  rb_ePathfinderFailed = rb_define_class("PathfinderFailed",
                                         rb_eStandardError);

  rb_mPathfinder = rb_define_module("Pathfinder");
  /*
   * rb_define_module_function makes actually two calls:
   *  - rb_define_private_method
   *  - rb_define_singleton_method
   *
   *  so the function can be called as a mixin function and
   *  is directly accessable by the module
   */
  rb_define_module_function(rb_mPathfinder, "compile_to_sql",
                            method_compile_to_sql, 1);
  rb_define_module_function(rb_mPathfinder, "compile_to_dot",
                            method_compile_to_dot, 1);
  rb_define_module_function(rb_mPathfinder, "optimize",
                            method_optimize,      -1);
}

#define NO_OPT ((char*)"P")
#define PF_RUBY_OPT ((char*)"EOIKCG_VG_JIS_I_GECSVR_OIK_NQU_}" \
                            "MT{JISAI_GYECSVR_QU_}MT{JISAI_OI" \
                            "K_GYECSVR_QU_CGP[I")
#define PF_MONET_OPT ((char*)"EOIKCG_VG_JIS_I_GECSVR_OIK_N}MT" \
                             "{JISAI_GYECSVR_}MT{JISAI_OIK_GY" \
                             "ECSVR_DC_GP")

static VALUE
compile_wrapper(VALUE query, PFoutput_format_t fmt, char *opt) {
  /* errorbuffer
   * Pathfinder is supposed to write to an error buffer we allocate
   * to make sure that we can access it even if pathfinder is failing
   */
  char err[ERR_SIZE];
  err[0] = (char)'\0';

  /* pathfinder allocates the result for us */
  char *res = NULL;

  /* get the native string-pointer out of the ruby string object.
   * In the case ruby's not able to convert it raise a type error
   */
  /* FIXME think about using rubies tainted mechanism, to make the whole
   *       thing saver. When the string is coming from an unreliable source
   *       it fails with a SecurityError Exception. Is that what we want? 
   *       it is worth trying it in ferrycore :) */
  SafeStringValue(query);
  char *queryc = StringValuePtr(query);

  /* the output "res" strongly depends on the input xml-query */
  int ret = PFcompile_ferry_opt(
                             &res,   /* the compiled result     */
                             err,    /* error message           */
                             queryc, /* the xml query plan      */
                             fmt,    /* the output format       */
                             opt);   /* the optimization string */
     
  /* check if the compilation was successful and return the result */
  if(ret == 0)
    return rb_str_new2(res);
  /* in every other case raise an exception with the exact err-message */
  else
    rb_raise(rb_ePathfinderFailed,
             "Pathfinder failed with the following exception:\n%s",
             err);
}

static VALUE
method_compile_to_sql(VALUE self, VALUE query) {
  (void)self;
  return compile_wrapper(query, PFoutput_format_sql, NO_OPT);
}

static VALUE
method_compile_to_dot(VALUE self, VALUE query) {
  (void)self;
  return compile_wrapper(query, PFoutput_format_dot, NO_OPT);
}

static VALUE
method_optimize(int argc, VALUE* argv, VALUE self) {
   (void)self;
   VALUE v_query = Qnil; 
   VALUE v_opt = Qnil;
   char *opt   = NULL;

   /* handling the optional optimization string parameter */
   rb_scan_args(argc, argv,
                "11",   /* one required argument, one optional argument */
                &v_query, &v_opt);

   if (NIL_P(v_opt)) {
     /* setting the default value */
     opt = PF_RUBY_OPT;
   } else {
     SafeStringValue(v_opt);
     opt = StringValuePtr(v_opt);
   }

   return compile_wrapper(v_query, PFoutput_format_xml, opt);
}

