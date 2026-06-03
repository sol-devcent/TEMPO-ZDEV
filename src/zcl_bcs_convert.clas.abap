class ZCL_BCS_CONVERT definition
  public
  final
  create public .

*"* public components of class ZCL_BCS_CONVERT
*"* do not include other source files here!!!
public section.

  constants GC_TAB type CHAR1 value CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB ##NO_TEXT.
  constants GC_CRLF type CHAR2 value CL_ABAP_CHAR_UTILITIES=>CR_LF ##NO_TEXT.

  class-methods RAW_TO_SOLIX
    importing
      !IT_SOLI type SOLI_TAB
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
    exporting
      !ET_SOLIX type SOLIX_TAB
      !EV_SIZE type SO_OBJ_LEN
    raising
      CX_BCS .
  class-methods RAW_TO_STRING
    importing
      !IT_SOLI type SOLI_TAB
    returning
      value(EV_STRING) type STRING
    raising
      CX_BCS .
  class-methods RAW_TO_XSTRING
    importing
      !IT_SOLI type SOLI_TAB
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
    returning
      value(EV_XSTRING) type XSTRING
    raising
      CX_BCS .
  class-methods TXT_TO_SOLIX
    importing
      !IT_SOLI type SOLI_TAB
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
      !IV_SIZE type I optional
    exporting
      !ET_SOLIX type SOLIX_TAB
      !EV_SIZE type SO_OBJ_LEN
    raising
      CX_BCS .
  class-methods TXT_TO_STRING
    importing
      !IT_SOLI type SOLI_TAB
      !IV_SIZE type I optional
    returning
      value(EV_STRING) type STRING .
  class-methods TXT_TO_XSTRING
    importing
      !IT_SOLI type SOLI_TAB
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
      !IV_SIZE type I optional
    returning
      value(EV_XSTRING) type XSTRING
    raising
      CX_BCS .
  class-methods STRING_TO_SOLI
    importing
      !IV_STRING type STRING
    returning
      value(ET_SOLI) type SOLI_TAB .
  class-methods STRING_TO_SOLIX
    importing
      !IV_STRING type STRING
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
    exporting
      !ET_SOLIX type SOLIX_TAB
      !EV_SIZE type SO_OBJ_LEN
    raising
      CX_BCS .
  class-methods STRING_TO_XSTRING
    importing
      !IV_STRING type STRING
      !IV_CONVERT_CP type OS_BOOLEAN default 'X'
      !IV_CODEPAGE type ABAP_ENCOD optional
      !IV_ADD_BOM type OS_BOOLEAN optional
    returning
      value(EV_XSTRING) type XSTRING
    raising
      CX_BCS .
  class-methods SOLI_TO_SOLIX
    importing
      !IT_SOLI type SOLI_TAB
    returning
      value(ET_SOLIX) type SOLIX_TAB
    raising
      CX_BCS .
  class-methods XSTRING_TO_SOLIX
    importing
      !IV_XSTRING type XSTRING
    returning
      value(ET_SOLIX) type SOLIX_TAB .
  class-methods SOLIX_TO_XSTRING
    importing
      !IT_SOLIX type SOLIX_TAB
      !IV_SIZE type I optional
    returning
      value(EV_XSTRING) type XSTRING .
protected section.
*"* protected components of class CL_BCS_CONVERT
*"* do not include other source files here!!!
private section.
*"* private components of class CL_BCS_CONVERT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BCS_CONVERT IMPLEMENTATION.


method RAW_TO_SOLIX.

  data lv_string type string.
  data lv_xstring type xstring.

  lv_string = raw_to_string( it_soli ).

  lv_xstring = string_to_xstring(
      iv_string   = lv_string
      iv_codepage = iv_codepage
      iv_add_bom  = iv_add_bom ).

  et_solix = xstring_to_solix( lv_xstring ).
  ev_size  = xstrlen( lv_xstring ).

endmethod.


method RAW_TO_STRING.

  field-symbols <ls_soli> type soli.

* cut of spaces at end of each line
* add crlf at end of each line

* this exactly how so_raw_to_rtf did it:
  loop at it_soli assigning <ls_soli>.
    concatenate ev_string <ls_soli> cl_abap_char_utilities=>cr_lf
    into ev_string.
  endloop.

endmethod.


method RAW_TO_XSTRING.

  data lv_string type string.

  lv_string = raw_to_string( it_soli ).

  ev_xstring = string_to_xstring(
    iv_string   = lv_string
    iv_codepage = iv_codepage
    iv_add_bom  = iv_add_bom ).

endmethod.


method SOLIX_TO_XSTRING.

  field-symbols <ls_solix> type solix.
  data lv_rest type i.
  data lv_row_len type i.

  describe table it_solix.
  lv_row_len = sy-tleng.

  loop at it_solix assigning <ls_solix>.
    if iv_size > 0.
      lv_rest = iv_size - xstrlen( ev_xstring ).
      if lv_rest le lv_row_len.
*       last line to process
        concatenate ev_xstring <ls_solix>-line(lv_rest)
        into ev_xstring in byte mode.
        exit.
      endif.
    endif.
    concatenate ev_xstring <ls_solix>-line
    into ev_xstring in byte mode.
  endloop.

endmethod.


method SOLI_TO_SOLIX.

  data lv_row_len type i.
  data lv_offset  type i.
  data lv_convert type c.
  data ls_soli    type soli.
  data ls_solix   type solix.

  field-symbols <lv_x> type x.

  if cl_abap_char_utilities=>charsize > 1. "unicode
    describe field ls_soli-line length lv_row_len in character mode.
    lv_offset = lv_row_len / 2.
    loop at it_soli into ls_soli.
      if ls_soli-line+lv_offset is not initial.
        lv_convert = 'X'.
        exit.
      endif.
    endloop.
  endif.

  assign ls_soli to <lv_x> casting.

  if lv_convert is initial.
    loop at it_soli into ls_soli.
      ls_solix-line = <lv_x>.
      append ls_solix to et_solix.
    endloop.
  else.
    loop at it_soli into ls_soli.
      ls_solix-line = <lv_x>(lv_row_len).
      append ls_solix to et_solix.
      ls_solix-line = <lv_x>+lv_row_len.
      append ls_solix to et_solix.
    endloop.
  endif.

endmethod.


method STRING_TO_SOLI.

  data lv_size type i.
  data lv_off type i.
  data ls_soli type soli.
  data lv_rows type i.
  data lv_last_row_len type i.
  data lv_row_len type i.

  describe field ls_soli-line length lv_row_len in character mode.
  lv_size = strlen( iv_string ).

  lv_rows = lv_size div lv_row_len.
  lv_last_row_len = lv_size mod lv_row_len.

  do lv_rows times.
    ls_soli-line = iv_string+lv_off(lv_row_len).
    append ls_soli to et_soli.
    add lv_row_len to lv_off.
  enddo.

  if lv_last_row_len > 0.
    ls_soli-line = iv_string+lv_off(lv_last_row_len).
    append ls_soli to et_soli.
  endif.

endmethod.


method STRING_TO_SOLIX.

  data lv_xstring type xstring.

  lv_xstring = string_to_xstring(
    iv_string     = iv_string
    iv_codepage   = iv_codepage
    iv_add_bom    = iv_add_bom ).

  et_solix = xstring_to_solix( lv_xstring ).
  ev_size  = xstrlen( lv_xstring ).

endmethod.


method STRING_TO_XSTRING.

  data lo_conv type ref to cl_abap_conv_out_ce.
  data lv_bom type xstring.
  data lv_xbuf type xstring.
  data lv_cp type abap_encod.

  try.

      if iv_convert_cp is initial.

        export p = iv_string to data buffer lv_xbuf.
        import p = ev_xstring from data buffer lv_xbuf
               in char-to-hex mode.

      else.

        if iv_codepage is initial.
          lv_cp = cl_sx_mime_singlepart=>get_sx_node_codepage( ).
        else.
          lv_cp = iv_codepage.
        endif.

*       convert string to xstring using class cl_abap_conv_out_ce
*       in this form available also in 620
        lo_conv = cl_abap_conv_out_ce=>create(
          encoding = lv_cp
          ignore_cerr = 'X' ).
        lo_conv->write( data = iv_string ).
        ev_xstring = lo_conv->get_buffer( ).

*       add the byte order mark
        if iv_add_bom = 'X'.
          case lv_cp.
            when '4110'.                                    "UTF-8
              lv_bom = cl_abap_char_utilities=>byte_order_mark_utf8.
            when '4102'.                                    "UTF-16BE
              lv_bom = cl_abap_char_utilities=>byte_order_mark_big.
            when '4103'.                                    "UTF-16LE
              lv_bom = cl_abap_char_utilities=>byte_order_mark_little.
          endcase.
          if lv_bom is not initial.
            concatenate lv_bom ev_xstring into ev_xstring in byte mode.
          endif.
        endif.
      endif.

    catch cx_root.                                       "#EC *
      raise exception type cx_bcs
        exporting
          error_type = cx_bcs=>creation_failed.

  endtry.

endmethod.


method TXT_TO_SOLIX.

  data lv_string type string.
  data lv_xstring type xstring.

  lv_string = txt_to_string(
    it_soli = it_soli
    iv_size = iv_size ).

  lv_xstring = string_to_xstring(
      iv_string     = lv_string
      iv_codepage   = iv_codepage
      iv_add_bom    = iv_add_bom ).

  et_solix = xstring_to_solix( lv_xstring ).
  ev_size  = xstrlen( lv_xstring ).

endmethod.


method TXT_TO_STRING.

  field-symbols <ls_soli> type soli.
  data lv_lines type i.

* do not cut of spaces at end of each line
* do not add crlf at end of each line

* but:
* closing spaces at the end of the last line
* are cut off per default.
* Only if iv_size is set, resulting string is
* cut off exactly after iv_size characters

  lv_lines = lines( it_soli ).

  loop at it_soli assigning <ls_soli>.
    if sy-tabix < lv_lines or iv_size > 0.
      concatenate ev_string space into ev_string
        separated by <ls_soli>-line.
    else.
      concatenate ev_string <ls_soli>-line into ev_string.
    endif.
  endloop.

  if iv_size > 0 and iv_size < strlen( ev_string ).
    ev_string = ev_string(iv_size).
  endif.

endmethod.


method TXT_TO_XSTRING.

  data lv_string type string.

  lv_string = txt_to_string(
    it_soli = it_soli
    iv_size = iv_size ).

  ev_xstring = string_to_xstring(
      iv_string     = lv_string
      iv_codepage   = iv_codepage
      iv_add_bom    = iv_add_bom ).

endmethod.


method XSTRING_TO_SOLIX.

  data lv_size type i.
  data lv_off type i.
  data ls_solix type solix.
  data lv_rows type i.
  data lv_last_row_len type i.
  data lv_row_len type i.

  describe table et_solix.
  lv_row_len = sy-tleng.
  lv_size = xstrlen( iv_xstring ).

  lv_rows = lv_size div lv_row_len.
  lv_last_row_len = lv_size mod lv_row_len.
  do lv_rows times.
    ls_solix-line = iv_xstring+lv_off(lv_row_len).
    append ls_solix to et_solix.
    add lv_row_len to lv_off.
  enddo.
  if lv_last_row_len > 0.
    ls_solix-line = iv_xstring+lv_off(lv_last_row_len).
    append ls_solix to et_solix.
  endif.

endmethod.
ENDCLASS.
