*----------------------------------------------------------------------*
*   INCLUDE ZABP_SMARTFORM                                             *
*----------------------------------------------------------------------*

data: gv_ctrl_param     like    ssfctrlop,
*{   REPLACE        P01K900160                                        1
*\      gv_output_opt     like    ssfcompop,
      gv_output_opt    type    ssfcompop,  "By SAP_DEV06 26-03-2007.
*}   REPLACE
      gv_smrt_funcmod   type    rs38l_fnam,
      gv_ssfscreen      like    ssfscreen.

data: t_lines    like tline occurs  0 with header line,
      gv_tdnam    like rssce-tdname.


*&---------------------------------------------------------------------*
*&      Form  f_determine_smrt_funcmod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TDFORM  text
*      <--P_D_SMRT_FUNCMOD  text
*----------------------------------------------------------------------*
form f_determine_smrt_funcmod using    fu_tdform  type  tdsfname
                              changing fc_funcmod type  rs38l_fnam
                                       fc_subrc.

  clear: fc_funcmod, fc_subrc.
  clear: gv_ctrl_param,
         gv_output_opt,
         gv_smrt_funcmod,
         gv_ssfscreen.


  if fu_tdform is initial.
    fc_subrc = 8.
  else.
    set parameter id 'SSFNAME' field fu_tdform.
    call function 'SSF_FUNCTION_MODULE_NAME'
      exporting
        formname                 = fu_tdform
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
     importing
       fm_name                  = fc_funcmod
     exceptions
       no_form                  = 1
       no_function_module       = 2
       others                   = 3.

    fc_subrc = sy-subrc.

  endif.

* set output options
  gv_output_opt-tddest    = p_dest.
  clear: gv_output_opt-tdimmed.
  if p_disp is initial.
    gv_output_opt-tdimmed   = 'X'.
  endif.

  gv_output_opt-tdnewid   = 'X'.

  gv_ctrl_param-preview   = p_disp.
  gv_ctrl_param-no_dialog = 'X'.

  gv_ssfscreen-fname = fu_tdform.


endform.                    " f_determine_smrt_funcmod




*&---------------------------------------------------------------------*
*&      Form  F_GET_SIGNOFF
*&---------------------------------------------------------------------*
form f_get_stdtext using fu_tdnam fu_brnch fu_idkey fu_reslt.
  data: ld_tdnam like rssce-tdname,
        ld_idkey(40),
        ld_reslt(72),
        ld_keyin(40).

  clear fu_reslt.
  ld_keyin = fu_idkey.
  concatenate fu_tdnam fu_brnch into ld_tdnam.
  if ld_tdnam ne gv_tdnam or t_lines[] is initial..
    refresh: t_lines.
    call function 'READ_TEXT'
      exporting
*     CLIENT                        = SY-MANDT
        id                            = 'ST'
        language                      = sy-langu
        name                          = ld_tdnam
        object                        = 'TEXT'
*     ARCHIVE_HANDLE                = 0
*     LOCAL_CAT                     = ' '
*   IMPORTING
*     HEADER                        =
      tables
        lines                         = t_lines
     exceptions
       id                            = 1
       language                      = 2
       name                          = 3
       not_found                     = 4
       object                        = 5
       reference_check               = 6
       wrong_access_to_archive       = 7
       others                        = 8.
  else.
    gv_tdnam = ld_tdnam.
    gv_tdnam = ld_tdnam.
    translate ld_keyin to upper case.
  endif.
  loop at t_lines.
    split t_lines-tdline at ':' into ld_idkey ld_reslt.
    translate ld_idkey to upper case.
    if ld_keyin ne space and ld_keyin eq ld_idkey.
      fu_reslt = ld_reslt.
    endif.
  endloop.
endform.                    " F_GET_SIGNOFF
