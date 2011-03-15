# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{switch}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Manuel Mayr"]
  s.date = %q{2010-02-05}
  s.description = %q{}
  s.email = %q{mayr@informatik.uni-tuebingen.de}
  s.extra_rdoc_files = [
    "History.txt",
  ]
  s.extensions = ["ext/extconf.rb"]
  s.files = [
#    ".gitignore",
#    ".gitmodules",
    "History.txt",
    "switch.gemspec",
    "lib/switch.rb",
    "lib/switch/dispatcher.rb",
    "lib/switch/query_language.rb",
    "lib/switch/query_language/queryables.rb",
    "lib/switch/query_language/queryables/atom_constructor.rb",
    "lib/switch/query_language/queryables/queryable.rb",
    "lib/switch/query_language/queryables/lambda.rb",
    "lib/switch/query_language/queryables/variable.rb",
    "lib/switch/query_language/queryables/types.rb",
    "lib/switch/query_language/queryables/record_field_variable.rb",
    "lib/switch/query_language/queryables/record_rest_variable.rb",
    "lib/switch/query_language/queryables/record_single_variable.rb",
    "lib/switch/query_language/queryables/standard_wrapper.rb",
    "lib/switch/query_language/queryables/combinators.rb",
    "lib/switch/query_language/queryables/combinators/lambda_handling.rb",
    "lib/switch/query_language/queryables/combinators/block_argument.rb",
    "lib/switch/query_language/queryables/combinators/no_argument.rb",
    "lib/switch/query_language/queryables/combinators/one_argument_block_argument.rb",
    "lib/switch/query_language/queryables/combinators/one_argument.rb",
    "lib/switch/query_language/queryables/combinators/one_value_argument.rb",
    "lib/switch/query_language/queryables/combinators/variable_arguments.rb",
    "lib/switch/query_language/queryables/combinators/combinator.rb",
    "lib/switch/query_language/queryables/combinators/all.rb",
    "lib/switch/query_language/queryables/combinators/any.rb",
    "lib/switch/query_language/queryables/combinators/none.rb",
    "lib/switch/query_language/queryables/combinators/one.rb",
    "lib/switch/query_language/queryables/combinators/append.rb",
    "lib/switch/query_language/queryables/combinators/flatten.rb",
    "lib/switch/query_language/queryables/combinators/cross.rb",
    "lib/switch/query_language/queryables/combinators/distinct.rb",
    "lib/switch/query_language/queryables/combinators/drop.rb",
    "lib/switch/query_language/queryables/combinators/drop_while.rb",
    "lib/switch/query_language/queryables/combinators/group_with.rb",
    "lib/switch/query_language/queryables/combinators/member.rb",
    "lib/switch/query_language/queryables/combinators/at.rb",
    "lib/switch/query_language/queryables/combinators/first.rb",
    "lib/switch/query_language/queryables/combinators/sort_by.rb",
    "lib/switch/query_language/queryables/combinators/map.rb",
    "lib/switch/query_language/queryables/combinators/max_by.rb",
    "lib/switch/query_language/queryables/combinators/min_by.rb",
    "lib/switch/query_language/queryables/combinators/flat_map.rb",
    "lib/switch/query_language/queryables/combinators/sum.rb",
    "lib/switch/query_language/queryables/combinators/avg.rb",
    "lib/switch/query_language/queryables/combinators/take.rb",
    "lib/switch/query_language/queryables/combinators/take_while.rb",
    "lib/switch/query_language/queryables/combinators/select.rb",
    "lib/switch/query_language/queryables/combinators/reject.rb",
    "lib/switch/query_language/queryables/combinators/zip.rb",
    "lib/switch/query_language/queryables/combinators/unzip.rb",
    "lib/switch/query_language/queryables/combinators/count.rb",
    "lib/switch/query_language/queryables/combinators/partition.rb",
    "lib/switch/query_language/queryables/combinators/reverse.rb",
    "lib/switch/query_language/queryables/combinators/unwrap.rb",
    "lib/switch/query_language/queryables/aggregates.rb",
    "lib/switch/query_language/queryables/aggregates/max.rb",
    "lib/switch/query_language/queryables/aggregates/max_over.rb",
    "lib/switch/query_language/queryables/aggregates/min.rb",
    "lib/switch/query_language/queryables/aggregates/min_over.rb",
    "lib/switch/query_language/queryables/aggregates/sum_over.rb",
    "lib/switch/query_language/queryables/aggregates/avg_over.rb",
    "lib/switch/query_language/queryables/aggregates/uniq.rb",
    "lib/switch/query_language/queryables/arithmetic.rb",
    "lib/switch/query_language/queryables/arithmetic/binary_arith.rb",
    "lib/switch/query_language/queryables/arithmetic/plus.rb",
    "lib/switch/query_language/queryables/arithmetic/minus.rb",
    "lib/switch/query_language/queryables/arithmetic/multiplication.rb",
    "lib/switch/query_language/queryables/arithmetic/division.rb",
    "lib/switch/query_language/queryables/comparables.rb",
    "lib/switch/query_language/queryables/comparables/binary_comp.rb",
    "lib/switch/query_language/queryables/comparables/equal.rb",
    "lib/switch/query_language/queryables/comparables/unequal.rb",
    "lib/switch/query_language/queryables/comparables/less.rb",
    "lib/switch/query_language/queryables/comparables/less_than_or_equal.rb",
    "lib/switch/query_language/queryables/comparables/greater.rb",
    "lib/switch/query_language/queryables/comparables/greater_than_or_equal.rb",
    "lib/switch/query_language/queryables/comparables/or.rb",
    "lib/switch/query_language/queryables/comparables/and.rb",
    "lib/switch/query_language/queryables/table.rb",
    "lib/switch/query_language/queryables/table/attribute.rb",
    "lib/switch/query_language/queryables/table/attribute_accessor.rb",
    "lib/switch/query_language/queryables/table/record.rb",
    "lib/switch/query_language/queryables/table/table.rb",
    "lib/switch/query_language/queryables/atomics.rb",
    "lib/switch/query_language/queryables/atomics/atomic.rb",
    "lib/switch/query_language/queryables/atomics/dbl.rb",
    "lib/switch/query_language/queryables/atomics/int.rb",
    "lib/switch/query_language/queryables/atomics/str.rb",
    "lib/switch/query_language/queryables/atomics/boolean.rb",
    "lib/switch/query_language/queryables/atomics/array.rb",
    "lib/switch/query_language/queryables/atomics/empty_array.rb",
    "lib/switch/query_language/queryables/atomics/one_element_array.rb",
    "lib/switch/query_language/normalization.rb",
    "lib/switch/query_language/normalization/normalization.rb",
    "lib/switch/inferences.rb",
    "lib/switch/inferences/boxing_inference.rb",
    "lib/switch/inferences/boxing_inference/box.rb",
    "lib/switch/inferences/boxing_inference/boxing_inference.rb",
    "lib/switch/inferences/boxing_inference/unbox.rb",
    "lib/switch/inferences/boxing_inference/conformance.rb",
    "lib/switch/inferences/implementation_type_inference.rb",
    "lib/switch/inferences/implementation_type_inference/implementation_type_inference.rb",
    "lib/switch/inferences/implementation_type_inference/implementation_types.rb",
    "lib/switch/core_extensions.rb",
    "lib/switch/core_extensions/inflector.rb",
    "lib/switch/core_extensions/array.rb",
    "lib/switch/core_extensions/module.rb",
    "lib/switch/core_extensions/string.rb",
    "lib/switch/core_extensions/symbol.rb",
    "lib/switch/translation.rb",
    "lib/switch/translation/translate_to_algebra.rb",
    "lib/switch/translation/exceptions.rb",
    "lib/switch/engines.rb",
    "lib/switch/engines/ferry.rb",
    "lib/switch/engines/ferry/engine.rb",
    "lib/switch/engines/ferry/pathfinder.rb",
    "lib/switch/engines/ferry/queryable.rb",
    "lib/switch/engines/ferry/table.rb",
    "lib/switch/engines/ferry/query_plan.rb",
    "lib/switch/engines/ferry/resultset_factory.rb",
    "lib/switch/engines/ferry/resultset.rb",

    "ext/extconf.rb",
    "ext/pathfinder.c",
    "ext/pathfinder.h"
  ]
  s.homepage = %q{http://www-db.informatik.uni-tuebingen.de}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{switch}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{}
  s.test_files = []
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<locomotive>, [">= 0.0.1"])
      s.add_runtime_dependency(%q<activerecord>)
      s.add_runtime_dependency(%q<roxml>)
    else
      s.add_dependency(%q<locomotive>, [">= 0.0.1"])
      s.add_dependency(%q<activerecord>)
      s.add_dependency(%q<roxml>)
    end
  else
    s.add_dependency(%q<locomotive>, [">= 0.0.1"])
    s.add_dependency(%q<activerecord>)
    s.add_dependency(%q<roxml>)
  end
end
