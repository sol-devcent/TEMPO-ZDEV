* include zstdxin_atz.
data: d_atz_subrc like sy-subrc,
      d_atz_errxt value 'X', "Exit loop after not Authorize
      d_atz_msgty value 'E', "Message type
      d_atz_dspmg value 'X'. "Flag for display message.

data: d_atz_vkorg like vbak-vkorg,
      d_atz_vtweg like vbak-vtweg,
      d_atz_spart like vbak-spart,
      d_atz_fkart like vbrk-fkart,
      d_atz_vstel like likp-vstel.

constants: c_atz_create(2) value '01',
           c_atz_maintain(2) value '02',
           c_atz_display(2) value '03',
           c_atz_print(2) value '04',
           c_atz_reprint(2) value '05'.

data: begin of t_azt_werks occurs 0,
        werks like t001w-werks,
        name1 like t001w-name1,
      end of t_azt_werks.

data: begin of t_azt_bukrs occurs 0,
        bukrs like t001-bukrs,
        butxt like t001-butxt,
      end of t_azt_bukrs.

data: begin of t_azt_gsber occurs 0,
        gsber like tgsb-gsber,
        gtext like tgsbt-gtext,
      end of t_azt_gsber.

data: begin of t_azt_vstel occurs 0,
        vstel like tvstt-vstel,
        vtext like tvstt-vtext,
      end of t_azt_vstel.


define macro_atz_error_message.
  d_atz_subrc = sy-subrc.
  if d_atz_dspmg ne space and d_atz_subrc ne 0.
    case &3.
      when '03'.
        message id 'ZAB' type d_atz_msgty number 000 with
           'You are not authorized to'
           'DISPLAY data for' &1 &2.
      when '02'.
        message id 'ZAB' type d_atz_msgty number 000 with
           'You are not authorized to'
           'MAINTAIN data for' &1 &2.
      when '01'.
        message id 'ZAB' type d_atz_msgty number 000 with
           'You are not authorized to'
           'CREATE data for' &1 &2.
      when '04'.
        message id 'ZAB' type d_atz_msgty number 000 with
           'You are not authorized to'
           'PRINT data for' &1 &2.
      when '05'.
        message id 'ZAB' type d_atz_msgty number 000 with
           'You are not authorized to'
           'REPRINT data for' &1 &2.
    endcase.
  endif.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Plant (WERKS) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_werks.
  authority-check object 'M_MATE_WRK'
           id 'WERKS' field &1
           id 'ACTVT' field &2.
  macro_atz_error_message 'Plant' &1 &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Company Code (BUKRS) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_bukrs.
  authority-check object 'F_BKPF_BUK'
           id 'BUKRS' field &1
           id 'ACTVT' field &2.
  macro_atz_error_message 'Company Code' &1 &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Sales Office (VKBUR) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_vkbur.
  authority-check object 'Z_VBAK_VKO'
           id 'VKBUR' field &1
           id 'ACTVT' field &2.
  macro_atz_error_message 'Sales Office' &1 &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Business Area (GSBER) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_gsber.
  authority-check object 'F_BKPF_GSB'
           id 'GSBER' field &1
           id 'ACTVT' field &2.
  macro_atz_error_message 'Business Area' &1 &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Sales Organization (VKORG) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_vkorg.
  authority-check object 'V_VBAK_VKO'
       id 'VKORG' field &1
       id 'VTWEG' dummy
       id 'SPART' dummy
       id 'ACTVT' field &2.
  macro_atz_error_message 'Sales organization' &1 &2.
end-of-definition.


*-----------------------------------------------------------------------
* &1 Sales Document (VBAK-VBELN) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_vbak_vbeln.
  select single vkorg vtweg spart from vbak
    into (d_atz_vkorg, d_atz_vtweg, d_atz_spart)
   where vbeln eq &1.
  authority-check object 'V_VBAK_VKO'
       id 'VKORG' field d_atz_vkorg
       id 'VTWEG' field d_atz_vtweg
       id 'SPART' field d_atz_spart
       id 'ACTVT' field &2.
  macro_atz_error_message 'Sales document' &1 &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Billing Document (VBRK-VBELN) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_vbrk_vbeln.
  select single vkorg fkart from vbrk
    into (d_atz_vkorg, d_atz_fkart)
   where vbeln eq &1.
  authority-check object 'V_VBRK_VKO'
       id 'VKORG' field d_atz_vkorg
       id 'ACTVT' field &2.
  macro_atz_error_message 'Sales Organization' d_atz_vkorg &2.

  authority-check object 'V_VBRK_FKA'
       id 'FKART' field d_atz_fkart
       id 'ACTVT' field &2.
  macro_atz_error_message 'Billing Type' d_atz_fkart &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Delivery Document (LIKP-VBELN) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_single_vbrk_vbeln.
  select single vstel from likp
    into d_atz_vstel
   where vbeln eq &1.
  authority-check object 'V_LIKP_VST'
                  id 'VSTEL' field d_atz_vstel
                  id 'ACTVT' field &2.
  macro_atz_error_message 'Shipping Point' d_atz_vstel &2.
end-of-definition.

*----------------------------------------------------------------------
* &1 Delivery Document (LIKP-VBELN) - SINGLE VALUE
* &2 Activity -> See CONSTANTS Declaration
*----------------------------------------------------------------------
define macro_atz_single_vstel.
  authority-check object 'V_LIKP_VST'
                  id 'VSTEL' field &1
                  id 'ACTVT' field &2.
  macro_atz_error_message 'Shipping Point' d_atz_vstel &2.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Plant (WERKS) - RANGES
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_ranges_werks.
  select werks name1 from t001w
    into table t_azt_werks
   where werks in &1.
  loop at t_azt_werks.
    macro_atz_single_werks t_azt_werks-werks &2.
    check d_atz_errxt ne space.
    exit.
  endloop.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Company Code (BUKRS) - RANGES
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_ranges_bukrs.
  select bukrs butxt from t001
    into table t_azt_bukrs
   where bukrs in &1.
  loop at t_azt_bukrs.
    macro_atz_single_bukrs t_azt_bukrs-bukrs &2.
    check d_atz_errxt ne space.
    exit.
  endloop.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Business Area (GSBER) - RANGES
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_ranges_gsber.
  select gsber gtext from tgsbt
    into table t_azt_gsber
   where spras eq sy-langu
     and gsber in &1.
  loop at t_azt_gsber.
    macro_atz_single_gsber t_azt_gsber-gsber &2.
    check d_atz_errxt ne space.
    exit.
  endloop.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Sales Organization (VKORG) - RANGES
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_ranges_vkorg.
  if &1 <> &2.
  endif.
*  select gsber gtext from tgsbt
*    into table t_azt_gsber
*   where spras eq sy-langu
*     and gsber in &1.
*  loop at t_azt_gsber.
*    macro_atz_single_gsber t_azt_gsber-gsber &2.
*    check d_atz_errxt ne space.
*    exit.
*  endloop.
end-of-definition.

*-----------------------------------------------------------------------
* &1 Shipping Point (VSTEL) - RANGES
* &2 Activity -> See CONSTANTS Declaration
*-----------------------------------------------------------------------
define macro_atz_ranges_vstel.
  select vstel vtext from tvstt
    into table t_azt_vstel
   where vstel in &1.
  loop at t_azt_vstel.
    macro_atz_single_vstel t_azt_vstel-vstel &2.
    check d_atz_errxt ne space.
    exit.
  endloop.
end-of-definition.
