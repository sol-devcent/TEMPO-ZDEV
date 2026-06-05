*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

class lcl_test definition
    for testing "#AU Risk_Level Harmless
    inheriting from cl_aunit_assert .
  private section .
    methods:
      setup ,
      teardown ,
      test_scalar for testing ,
      test_struct for testing ,
      test_itab for testing ,
      test_deep for testing .
    types:
      begin of t_struct ,
        c1 type string ,
        c2 type string ,
      end of t_struct .
    data:
      serializer type ref to cl_trex_json_serializer ,
      result type string .
endclass .
