REPORT ZS_SAC7_2 message-id zz no standard page heading
                                  line-count 63(3)
                                  line-size  255.


type-pools: slis,abap.

tables : mvke,
         mara,
         mard,
         s603,
         t001w,
         t001k,
         ekko,
         ekpo,
         ekbe,
         vbfa,
         mbew,
         t179,
         makt,
         mapr,
         prop,
         tvkol,
         *mver,
         knvv.

data begin of i_outpl occurs 0.
        include structure zsac7_tmp.
data:   kausf like marc-kausf,
        ratms like zsac7_tmp-BREMS,
        ratid(4),
        zeinr LIKE mara-zeinr,
        peran TYPE i,
     end of i_outpl.

data : begin of i_dataset occurs 0,
       WERKS(4),
       PRODH1(5),
       PRODH2(5),
       PRODH3(8),
       MATNR(18),
       MAKTX(35),
       UMMENGE(15),
       UMKZWI1(17),
       GUMENGE(15),
       GUKZWI1(17),
       NETSQTY(15),
       NETSAMT(17),
       BREMS(13),
       BRECV(13),
       BRETP(13),
       BREIT(13),
       BREUS(13),
       BRESP(13),
       BRETL(13),
       CWEMS(13),
       CWEIT(13),
       CWEUS(13),
       CWETL(13),
       STVAL(17),
       AVSQT(13),
       DOAMT(17),
       STRAT(17),
       basme(3),
       stwae(5),
       x1(13),
       x2(13),
       x3(13),
       x4(13),
       x5(13),
       x6(13),
       avqty(17),
       avamt(17),
       stratio(17),
       nsp(13),
       qdo_ip(15),
       vdo_ip(17),
       qcn_ip(15),
       vcn_ip(17),
       stkdo_ip(13),
       stkcn_ip(13),
       kausf(7),
       ratms(13),
       ratid(4).
data end of i_dataset.


data begin of i_s603 occurs 0.
     include structure s603.
data end of i_s603.

data begin of i_tvkol occurs 0.
     include structure tvkol.
data end of i_tvkol.

data : begin of i_matnr occurs 0,
       matnr like mara-matnr,
       prodh like mvke-prodh,
       zeinr LIKE mara-zeinr,
       end of i_matnr.

data : begin of i_plant occurs 0,
       plant like t001w-werks,
       end of i_plant.
data:       disvariant   like disvariant,
            eventcat     type slis_t_event,
            va_wbwbest   like s032-wbwbest,
            va_mbwbest   like s032-mbwbest,
            va_lgort     like s032-lgort,
            sw type i,
            va_verpr like mbew-verpr,
            va_peinh like mbew-peinh,
            va_nsp  LIKE KONP-KBETR,
            eventcat_ln  like line of eventcat,
            fieldcat     type slis_t_fieldcat_alv with header line,
            ihead        TYPE SLIS_T_LISTHEADER,
            ifoot        TYPE SLIS_T_LISTHEADER,
            ihead_ln     type SLIS_LISTHEADER,
            evtab        type SLIS_T_EVENT,
            evtab_ln     TYPE SLIS_ALV_EVENT,
            keyinfo      type slis_keyinfo_alv,
            layout       type slis_layout_alv,
            printcat     type slis_print_alv,
            sortcat      type slis_t_sortinfo_alv,
            sortcat_ln   like line of sortcat,
            it_text_ln   type LVC_T_TXTP,
            it_text      type LVC_T_TXTP with header line.

types : begin of t_line,
          v_text(1500) type c,
        end of t_line.
types : t_iline type t_line occurs 10.

data :  itabline type t_iline,
        wa_itabline type t_line.
*        pa_path(52).

DATA :  itabline_sut TYPE t_iline,
        wa_itabline_sut TYPE t_line.

DATA :  i_zplbc TYPE TABLE OF zplbc WITH HEADER LINE,
        gv_utd(1).

DATA :  BEGIN OF i_a890 OCCURS 0.
          INCLUDE STRUCTURE a890.
DATA :    werks TYPE werks_d,
        END OF i_a890.

DATA:        E_SAVE(1) TYPE C,
             ER_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
             ER_LAYOUT   TYPE SLIS_LAYOUT_ALV,
             ER_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV,
             ER_EVENTS   TYPE SLIS_T_EVENT,
             E_DEFAULT(1) TYPE C,
             E_EXIT(1) TYPE C,G_REPID LIKE SY-REPID,
             ER_VARIANT LIKE DISVARIANT,
             E_VARIANT LIKE DISVARIANT,
             l_dataset(40),
             E_STATUS TYPE SLIS_FORMNAME VALUE 'STANDARD_ER01',
             E_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND'.

DATA: gt_makt TYPE TABLE OF makt WITH HEADER LINE.

FIELD-SYMBOLS: <fs_outpl> LIKE i_outpl.

selection-screen begin of block a with frame title text-003.
parameter : pa_spmon like sy-datum OBLIGATORY   modif id A.
select-options : so_plant for t001w-werks,
*                 so_kunwe for s603-PKUNWE,
                 so_matnr for mara-matnr,
                 so_prodh for t179-prodh.
parameters : pa_month like bsid-monat default '6'.

SELECTION-SCREEN SKIP.
PARAMETERS : p_utd AS CHECKBOX DEFAULT ' ' USER-COMMAND utd.

selection-screen skip .
parameters : pa_path(52) lower case modif id ABC.
PARAMETERS : pa_path2(52) LOWER CASE MODIF ID aaa.

selection-screen end of block a.

selection-screen begin of block b with frame title text-006.
   SELECTION-SCREEN BEGIN OF LINE.
     PARAMETERS radio1 RADIOBUTTON GROUP GRP1 user-command ARS.
     SELECTION-SCREEN : COMMENT 5(35) TEXT-001.
     SELECTION-SCREEN END OF LINE.
     SELECTION-SCREEN BEGIN OF LINE.
     PARAMETERS radio2 RADIOBUTTON GROUP GRP1.
     SELECTION-SCREEN : COMMENT 5(35) TEXT-002.
     SELECTION-SCREEN END OF LINE.
selection-screen end of block b.

selection-screen begin of block c with frame title text-005.
   parameters : pa_vari type slis_vari.
selection-screen end of block c.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'A'.
*      SCREEN-INPUT = '0'.
       pa_spmon = sy-datum.
       MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'ABC' OR screen-group1 = 'AAA'.
      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF p_utd IS INITIAL AND screen-group1 = 'AAA'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

Initialization.
*  If sy-opsys = 'AIX'.
    pa_path = '/interface/SAC7/'.
    pa_path2 = '/interface/SAC7/sut/'.
*  Else.
*    pa_path = '\\tdsdev01\interface\SAC7\'.
*    pa_path2 = '\\tdsdev01\interface\SAC7\sut\'.
*  Endif.

start-of-selection.
*if radio1 eq 'X'.
   perform cek_auth.
   perform get_data.
   perform proses_data.
   PERFORM f_get_material_desc.
*else.
*   perform get_data1.
*    loop at i_outpl.
*    if pa_month eq '1'.
*       i_outpl-avqty = ( i_outpl-x1 ) / pa_month.
*    elseif pa_month eq '2'.
*       i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 ) / pa_month.
*    elseif pa_month eq '3'.
*       i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 )
*                       / pa_month.
*    elseif pa_month eq '4'.
*       i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 ) / pa_month.
*    elseif pa_month eq '5'.
*       i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 + i_outpl-x5 ) / pa_month.
*    elseif pa_month eq '6'.
*       i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 + i_outpl-x5 + i_outpl-x6 ) / pa_month.
*    endif.
*    modify i_outpl.
*    endloop.
*
*endif.
perform append_structure_alv.

end-of-selection.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM             = 'ZS_SAC7_2'
      I_BACKGROUND_ID                = 'ALV_BACKGROUND'
      IS_VARIANT                     = disvariant
      IT_FIELDCAT                    = fieldcat[]
      IT_EVENTS                      = evtab
      I_SAVE                         = 'A'
    TABLES
      T_OUTTAB                       = i_outpl
    EXCEPTIONS
      PROGRAM_ERROR                  = 1
      OTHERS                         = 2.


INITIALIZATION.
  PERFORM VARIANT_INIT.
* Get default variant
  ER_VARIANT = E_VARIANT.
  E_SAVE = 'A'.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
       EXPORTING
            I_SAVE     = E_SAVE
       CHANGING
            CS_VARIANT = ER_VARIANT
       EXCEPTIONS
            NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    PA_VARI = ER_VARIANT-VARIANT.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VARI.
  PERFORM F4_FOR_VARIANT.
sort i_outpl by werks prodh1 prodh2 prodh3 matnr.
*

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  data : l_filename(125) type c,
         l_date like sy-datum.


    l_date = sy-datum - 1.
    clear itabline. refresh itabline.
*    if pa_spmon+4(2) ne sy-datum+4(2).
*       concatenate PA_PATH '/' pa_spmon '.txt' into l_filename.
*    else.
     if radio1 = 'X'.
       concatenate PA_PATH pa_spmon '_C.txt' into l_filename.
     else.
       concatenate PA_PATH pa_spmon '_N.txt' into l_filename.
     endif.
*    endif.
    open dataset l_filename for input in text mode ENCODING DEFAULT.
    if sy-subrc eq 0.
      do.
        read dataset l_filename into wa_itabline.
        if sy-subrc <> 0.
          exit.
        endif.
        append wa_itabline to itabline.
      enddo.
    endif.
  close dataset l_filename.

  IF p_utd IS NOT INITIAL.
    PERFORM f_get_data_sut.
  ENDIF.
ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  proses_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_data.

  data : l_prodh1 like t179-prodh,
         l_prodh2 like t179-prodh,
         l_prodh3 like t179-prodh,
         l_len type i.

  loop at itabline into wa_itabline.
    i_dataset = wa_itabline.
    perform f_cek_aix.
    move-corresponding i_dataset to i_outpl.
    l_len = strlen( i_outpl-matnr ).
    check l_len eq 9.
    l_prodh1 = i_outpl-PRODH1.
    concatenate i_outpl-PRODH1 i_outpl-PRODH2 into l_prodh2.
    concatenate i_outpl-PRODH1 i_outpl-PRODH2 i_outpl-PRODH3 into
                l_prodh3.
    if i_outpl-werks in SO_PLANT and i_outpl-matnr in so_matnr and
       l_PRODH3 in so_prodh.
       AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
            ID 'PRODH' FIELD i_outpl-prodh1.
       if sy-subrc ne 0.
          continue.
       endif.
       perform f_append_itab.
    elseif i_outpl-werks in SO_PLANT and i_outpl-matnr in so_matnr and
           l_PRODH2 in so_prodh.
       AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
            ID 'PRODH' FIELD i_outpl-prodh1.
       if sy-subrc ne 0.
          continue.
       endif.
       perform f_append_itab.
    elseif i_outpl-werks in SO_PLANT and i_outpl-matnr in so_matnr and
           l_PRODH1 in so_prodh.
       AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
            ID 'PRODH' FIELD i_outpl-prodh1.
       if sy-subrc ne 0.
          continue.
       endif.
       perform f_append_itab.
    endif.
  endloop.
  clear itabline.
  refresh itabline.

  IF p_utd IS NOT INITIAL.
    PERFORM f_proses_data_sut.
    IF gv_utd IS NOT INITIAL.
      PERFORM f_hitung_average.
    ENDIF.
  ENDIF.
ENDFORM.                    " proses_data
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VARIANT_INIT.
 CLEAR E_VARIANT.
 E_VARIANT-REPORT = SY-REPID.

ENDFORM.                    " VARIANT_INIT
*&---------------------------------------------------------------------*
*&      Form  append_structure_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_structure_alv.

*    fieldcat-tabname = 'IT_OUTPL'. fieldcat-ref_tabname = 'ZSAC7_PL'.
    fieldcat-fieldname = 'WERKS'. fieldcat-ref_fieldname = 'WERKS'.
    fieldcat-SELTEXT_S = 'Plant'.
    fieldcat-SELTEXT_M = 'Plant'.
    fieldcat-SELTEXT_L = 'Plant'.
    fieldcat-col_pos = 1. fieldcat-key = 'X'.
    fieldcat-outputlen = 5. fieldcat-just = 'L'.
    append fieldcat. "clear fieldcat.

  fieldcat-fieldname = 'PRODH1'. fieldcat-ref_fieldname = 'PRODH1'.
  fieldcat-col_pos = 2. fieldcat-key = 'X'.
  fieldcat-outputlen = 11. fieldcat-just = 'L'.
  fieldcat-SELTEXT_S = 'Principal'.
  fieldcat-SELTEXT_M = 'Principal'.
  fieldcat-SELTEXT_L = 'Principal'.
  append fieldcat. "clear fieldcat.

* col 3
  fieldcat-fieldname = 'PRODH2'. fieldcat-ref_fieldname = 'PRODH2'.
  fieldcat-col_pos = 3. fieldcat-key = 'X'.
  fieldcat-outputlen = 11. fieldcat-just = 'L'.
  fieldcat-SELTEXT_S = 'Prd Group'.
  fieldcat-SELTEXT_M = 'Product Group'.
  fieldcat-SELTEXT_L = 'Product Group'.
  append fieldcat. "clear fieldcat.

* col 4
  fieldcat-fieldname = 'PRODH3'. fieldcat-ref_fieldname = 'PRODH3'.
  fieldcat-col_pos = 4. fieldcat-key = 'X'.
  fieldcat-outputlen = 11. fieldcat-just = 'L'.
  fieldcat-SELTEXT_S = 'Sub Prd'.
  fieldcat-SELTEXT_M = 'Sub Prd Group'.
  fieldcat-SELTEXT_L = 'Sub Product Group'.
  append fieldcat. "clear fieldcat.

* col 5
  fieldcat-fieldname = 'MATNR'. fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-col_pos = 5. fieldcat-key = 'X'.
  fieldcat-outputlen = 18. fieldcat-just = 'L'.
  fieldcat-SELTEXT_S = 'Material'.
  fieldcat-SELTEXT_M = 'Material'.
  fieldcat-SELTEXT_L = 'Material'.
  append fieldcat. "clear fieldcat.

* col 6
  fieldcat-fieldname = 'MAKTX'. fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-col_pos = 6. fieldcat-key = 'X'.
  fieldcat-outputlen = 25. fieldcat-just = 'L'.
  fieldcat-SELTEXT_S = 'Description'.
  fieldcat-SELTEXT_M = 'Description'.
  fieldcat-SELTEXT_L = 'Material Description'.
  append fieldcat. "clear fieldcat.

  clear fieldcat-key.
  fieldcat-just = 'R'.
* col 7
  fieldcat-fieldname = 'UMMENGE'. fieldcat-ref_fieldname = 'UMMENGE'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 7.
  fieldcat-outputlen = 15.
  fieldcat-SELTEXT_S = 'DO Qty'.
  fieldcat-SELTEXT_M = 'DO Quantity'.
  fieldcat-SELTEXT_L = 'DO Quantity'.
  fieldcat-decimals_out = '0'.
  append fieldcat. "clear fieldcat.

* col 8
  fieldcat-fieldname = 'UMKZWI1'. fieldcat-ref_fieldname = 'UMKZWI1'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 8.
  fieldcat-currency = 'IDR'.
  fieldcat-SELTEXT_S = 'DO Amount'.
  fieldcat-SELTEXT_M = 'DO Amount'.
  fieldcat-SELTEXT_L = 'DO Amount'.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

* col 9
  fieldcat-fieldname = 'GUMENGE'. fieldcat-ref_fieldname = 'GUMENGE'.
  fieldcat-do_sum = ' '.fieldcat-col_pos = 9.
  fieldcat-SELTEXT_S = 'CN Qty'.
  fieldcat-SELTEXT_M = 'CN Quantity'.
  fieldcat-SELTEXT_L = 'CN Quantity'.
  fieldcat-decimals_out = '0'.
  append fieldcat. "clear fieldcat.

* col 10
  fieldcat-fieldname = 'GUKZWI1'. fieldcat-ref_fieldname = 'GUKZWI1'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 10.
  fieldcat-SELTEXT_S = 'CN Amount'.
  fieldcat-SELTEXT_M = 'CN Amount'.
  fieldcat-SELTEXT_L = 'CN Amount'.
  fieldcat-currency = 'IDR'.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

* col 11
  fieldcat-fieldname = 'QDOCN_IP'.
  fieldcat-ref_fieldname = 'QDOCN_IP'.
  fieldcat-do_sum = ' '.fieldcat-col_pos = 11.
  fieldcat-SELTEXT_S = 'Sales Ip Qty'.
  fieldcat-SELTEXT_M = 'Sales Inproces Qty'.
  fieldcat-SELTEXT_L = 'Sales Inproces Quantity'.
  fieldcat-decimals_out = '0'.
  append fieldcat. "clear fieldcat.

* col 12
  fieldcat-fieldname = 'VDOCN_IP'.
  fieldcat-ref_fieldname = 'VDOCN_IP'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 12.
  fieldcat-SELTEXT_S = 'Sales Ip Amount'.
  fieldcat-SELTEXT_M = 'Sales Ip Amount'.
  fieldcat-SELTEXT_L = 'Sales Inproces Amount'.
  fieldcat-currency = 'IDR'.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

* col 13
  fieldcat-fieldname = 'NETSQTY'. fieldcat-ref_fieldname = 'NETSQTY'.
  fieldcat-SELTEXT_S = 'Net Sl Qty'.
  fieldcat-SELTEXT_M = 'Net Sales Qty'.
  fieldcat-SELTEXT_L = 'Net Sales Quantity'.
  fieldcat-decimals_out = '0'.
  FIELDCAT-QFIELDNAME   =  i_outpl-basme.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 13.
  append fieldcat. "clear fieldcat.

* col 14
  fieldcat-fieldname = 'NETSAMT'. fieldcat-ref_fieldname = 'NETSAMT'.
  fieldcat-SELTEXT_S = 'Net Sl Amt'.
  fieldcat-SELTEXT_M = 'Net Sales Amt'.
  fieldcat-SELTEXT_L = 'Net Sales Amount'.
  fieldcat-currency = 'IDR'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 14.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

* col 15
  fieldcat-fieldname = 'BREMS'. fieldcat-ref_fieldname = 'BREMS'.
  fieldcat-SELTEXT_S = 'Br Main St'.
  fieldcat-SELTEXT_M = 'Br Main Storage'.
  fieldcat-SELTEXT_L = 'Branch Stock Main Storage'.
  fieldcat-decimals_out = '0'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 15.
  append fieldcat. "clear fieldcat.

* col 16
  fieldcat-fieldname = 'BRECV'. fieldcat-ref_fieldname = 'BRECV'.
  fieldcat-SELTEXT_S = 'Br Canvass'.
  fieldcat-SELTEXT_M = 'Br Stock Canvass'.
  fieldcat-SELTEXT_L = 'Branch Stock Canvass'.
  fieldcat-decimals_out = '0'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 16.
  append fieldcat. "clear fieldcat.

* col 17
  fieldcat-fieldname = 'BRETP'. fieldcat-ref_fieldname = 'BRETP'.
  fieldcat-SELTEXT_S = 'Br Titipan'.
  fieldcat-SELTEXT_M = 'Br Stock Titipan'.
  fieldcat-SELTEXT_L = 'Branch Stock Titipan'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 17.
  append fieldcat. "clear fieldcat.

* col 18
  fieldcat-fieldname = 'BREIT'. fieldcat-ref_fieldname = 'BREIT'.
  fieldcat-SELTEXT_S = 'Br In Trns'.
  fieldcat-SELTEXT_M = 'Br In Transit'.
  fieldcat-SELTEXT_L = 'Branch Stock In Transit'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 18.
  append fieldcat. "clear fieldcat.

* col 19
  fieldcat-fieldname = 'BREUS'. fieldcat-ref_fieldname = 'BREUS'.
  fieldcat-SELTEXT_S = 'Br Unslbl'.
  fieldcat-SELTEXT_M = 'Br Unsalable'.
  fieldcat-SELTEXT_L = 'Branch Stock Unsalable'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 19.
  append fieldcat. "clear fieldcat.

** col 20
*  fieldcat-fieldname = 'BRESP'. fieldcat-ref_fieldname = 'BRESP'.
*  fieldcat-SELTEXT_S = 'Br St Pnt'.
*  fieldcat-SELTEXT_M = 'Br Stock Point'.
*  fieldcat-SELTEXT_L = 'Branch Stock Point'.
*  fieldcat-do_sum = ' '. fieldcat-col_pos = 20.
*  append fieldcat. "clear fieldcat.

* col 21
  fieldcat-fieldname = 'STKDOCN_IP'.
  fieldcat-ref_fieldname = 'STKDOCN_IP'.
  fieldcat-SELTEXT_S = 'Stock Ip'.
  fieldcat-SELTEXT_M = 'Stock Inprocess'.
  fieldcat-SELTEXT_L = 'Stock Inprocess'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 21.
  append fieldcat. "clear fieldcat.

* col 22
  fieldcat-fieldname = 'BRETL'. fieldcat-ref_fieldname = 'BRETL'.
  fieldcat-SELTEXT_S = 'Br Total'.
  fieldcat-SELTEXT_M = 'Br Stock Total'.
  fieldcat-SELTEXT_L = 'Branch Stock Total'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 22.
  append fieldcat. "clear fieldcat.


* col 23
  fieldcat-fieldname = 'STVAL'. fieldcat-ref_fieldname = 'STVAL'.
  fieldcat-SELTEXT_S = 'St Value'.
  fieldcat-SELTEXT_M = 'Stock Value'.
  fieldcat-SELTEXT_L = 'Total Stock Value'.
  fieldcat-currency = 'IDR'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 23.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

** col 24
  fieldcat-fieldname = 'DOAMT'. fieldcat-ref_fieldname = 'DOAMT'.
  fieldcat-SELTEXT_S = 'Value'.
  fieldcat-SELTEXT_M = 'Amount'.
  fieldcat-SELTEXT_L = 'Stock * NSP'.
  fieldcat-currency = 'IDR'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 24.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

* col 25
if pa_month >= 1.
  fieldcat-fieldname = 'X1'. fieldcat-ref_fieldname = 'X1'.
  fieldcat-SELTEXT_S = 'M -1'.
  fieldcat-SELTEXT_M = 'M -1'.
  fieldcat-SELTEXT_L = 'M -1'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 25.
  append fieldcat. "clear fieldcat.
endif.
** col 26
if pa_month >= 2.
  fieldcat-fieldname = 'X2'. fieldcat-ref_fieldname = 'X2'.
  fieldcat-SELTEXT_S = 'M -2'.
  fieldcat-SELTEXT_M = 'M -2'.
  fieldcat-SELTEXT_L = 'M -2'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 26.
  append fieldcat. "clear fieldcat.
endif.
** col 27
if pa_month >= 3.
  fieldcat-fieldname = 'X3'. fieldcat-ref_fieldname = 'X3'.
  fieldcat-SELTEXT_S = 'M -3'.
  fieldcat-SELTEXT_M = 'M -3'.
  fieldcat-SELTEXT_L = 'M -3'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 27.
  append fieldcat. "clear fieldcat.
endif.
** col 28
if pa_month >= 4.
  fieldcat-fieldname = 'X4'. fieldcat-ref_fieldname = 'X4'.
  fieldcat-SELTEXT_S = 'M -4'.
  fieldcat-SELTEXT_M = 'M -4'.
  fieldcat-SELTEXT_L = 'M -4'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 28.
  append fieldcat. "clear fieldcat.
endif.

** col 29
if pa_month >= 5.
  fieldcat-fieldname = 'X5'. fieldcat-ref_fieldname = 'X5'.
  fieldcat-SELTEXT_S = 'M -5'.
  fieldcat-SELTEXT_M = 'M -5'.
  fieldcat-SELTEXT_L = 'M -5'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 29.
  append fieldcat. "clear fieldcat.
endif.

** col 30
if pa_month >= 6.
  fieldcat-fieldname = 'X6'. fieldcat-ref_fieldname = 'X6'.
  fieldcat-SELTEXT_S = 'M -6'.
  fieldcat-SELTEXT_M = 'M -6'.
  fieldcat-SELTEXT_L = 'M -6'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 30.
  append fieldcat. "clear fieldcat.
endif.

** col 31
  fieldcat-fieldname = 'AVQTY'. fieldcat-ref_fieldname = 'AVQTY'.
  fieldcat-SELTEXT_S = 'Average Qty'.
  fieldcat-SELTEXT_M = 'Average Qty'.
  fieldcat-SELTEXT_L = 'Average Sales Qty'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 31.
  fieldcat-decimals_out = '2'.
  append fieldcat. "clear fieldcat.

** col 32
  fieldcat-fieldname = 'AVAMT'. fieldcat-ref_fieldname = 'AVAMT'.
  fieldcat-SELTEXT_S = 'Value'.
  fieldcat-SELTEXT_M = 'Amount'.
  fieldcat-SELTEXT_L = 'Average Sales Value'.
  fieldcat-currency = 'IDR'.
  fieldcat-do_sum = 'X'. fieldcat-col_pos = 32.
  append fieldcat. "clear fieldcat.
  clear fieldcat-currency.

** col 33
  fieldcat-fieldname = 'STRATIO'. fieldcat-ref_fieldname = 'STRATIO'.
  fieldcat-SELTEXT_S = 'Stock Ratio'.
  fieldcat-SELTEXT_M = 'Stock Ratio'.
  fieldcat-SELTEXT_L = 'Stock Ratio'.
  fieldcat-decimals_out = '3'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 33.
  append fieldcat. "clear fieldcat.

** col 34
  fieldcat-fieldname = 'KAUSF'. fieldcat-ref_fieldname = 'KAUSF'.
  fieldcat-SELTEXT_S = 'STD Stk Ratio'.
  fieldcat-SELTEXT_M = 'STD Stk Ratio'.
  fieldcat-SELTEXT_L = 'STD Stk Ratio'.
  fieldcat-decimals_out = '3'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 34.
  append fieldcat. "clear fieldcat.

** col 35
  fieldcat-fieldname = 'RATMS'. fieldcat-ref_fieldname = 'RATMS'.
  fieldcat-SELTEXT_S = 'Stk Rat Main'.
  fieldcat-SELTEXT_M = 'Stk Rat Main St'.
  fieldcat-SELTEXT_L = 'Stk Ratio Main St'.
  fieldcat-decimals_out = '3'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 35.
  append fieldcat. "clear fieldcat.

** col 36
  fieldcat-fieldname = 'RATID'. fieldcat-ref_fieldname = 'RATID'.
  fieldcat-do_sum = ' '. fieldcat-col_pos = 36.
  fieldcat-outputlen = 6.
  fieldcat-SELTEXT_S = 'Rat Id'.
  fieldcat-SELTEXT_M = 'Ratio Id'.
  fieldcat-SELTEXT_L = 'Ratio Id'.
  fieldcat-icon = 'X'.
  append fieldcat. "clear fieldcat.

  refresh evtab.
  evtab_ln-name = 'TOP_OF_PAGE'.
  evtab_ln-form = 'TOP_OF_PAGE'.
  append evtab_ln to evtab.

*  disvariant-variant = pa_vari.

ENDFORM.                    " append_structure_alv


*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  data: l_date(10).

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  ihead_ln-info = 'SAC7 Sales & Stock Report'.
  append ihead_ln to ihead.

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  write pa_spmon to l_date.
  concatenate 'Date :' l_date into ihead_ln-info
              separated by space.
  append ihead_ln to ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Date Process'.   write sy-datum to ihead_ln-info.
  append ihead_ln to ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Time Process'.   write sy-uzeit to ihead_ln-info.
  append ihead_ln to ihead.

**  if rd_plant eq space.
*  ihead_ln-key = 'Plant'.          ihead_ln-info = pa_werks.
*  append ihead_ln to ihead.
*  if rd_plant eq space.
*    ihead_ln-key = 'Sales Office'.   ihead_ln-info = pa_vkbur.
*    append ihead_ln to ihead.
*  endif.
**  else.
**    ihead_ln-key = 'Plant'.
**    if so_werks ne space.
**      if so_werks-high eq space.
**         ihead_ln-info = so_werks-low.
**      else.
**         concatenate so_werks-low '-' so_werks-high into ihead_ln-info
.
**      endif.
**    else.
**      ihead_ln-info = 'All'.
**    endif.
**    append ihead_ln to ihead.
**  endif.
*
*  ihead_ln-key = 'Principal'.
*  if so_princ ne space.
*      if so_princ-high eq space.
*         ihead_ln-info = so_princ-low.
*      else.
*         concatenate so_princ-low '-' so_princ-high into ihead_ln-info.
*      endif.
*  else.
*    ihead_ln-info = 'All'.
*  endif.
*  append ihead_ln to ihead.
*
*  ihead_ln-key = 'Customer Group'.
*  if so_kdgrp ne space.
*      if so_kdgrp-high eq space.
*         check so_kdgrp-sign = 'I'.
*         ihead_ln-info = so_kdgrp-low.
*      else.
*         check so_kdgrp-sign = 'I'.
*         concatenate so_kdgrp-low '-' so_kdgrp-high into ihead_ln-info.
*      endif.
*  else.
*    ihead_ln-info = 'All'.
*  endif.
*  append ihead_ln to ihead.
*
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            IT_LIST_COMMENTARY = ihead.
  refresh ihead.
*
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  nsp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nsp.
DATA : L_KNUMH LIKE A510-KNUMH.


 SELECT MAX( KNUMH ) INTO L_KNUMH FROM A510
 WHERE KAPPL EQ 'V' AND  KSCHL EQ 'ZN01'
 AND MATNR EQ I_outpl-MATNR.
 IF SY-SUBRC EQ 0.
    CLEAR va_NSP.
    SELECT SINGLE KBETR INTO va_NSP FROM KONP
    WHERE KNUMH EQ L_KNUMH
    AND  KSCHL EQ 'ZN01'.

 ENDIF.

ENDFORM.                    " nsp
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_FOR_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            IS_VARIANT          = E_VARIANT
            I_SAVE              = E_SAVE
*           it_default_fieldcat =
       IMPORTING
            E_EXIT              = E_EXIT
            ES_VARIANT          = DISVARIANT
       EXCEPTIONS
            NOT_FOUND = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF E_EXIT = SPACE.
      PA_VARI = DISVARIANT-VARIANT.
    ENDIF.
  ENDIF.


ENDFORM.                    " F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  get_avrg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_avrg.
data : l_spmon like s603-spmon,
       l_month(2) type n,
       l_year(4),
       l_month1(2) type n,
       l_spmon1 like s603-spmon,
       l_qty like mver-gsv01,
       l_count type i.


if pa_spmon+4(2) > pa_month.
   l_month1 = pa_month.
   l_spmon = pa_spmon -  1.
else.
   l_month1 = pa_spmon+4(2) - 1.
   l_month = pa_month -  l_month1 .
*   l_month = 12 - l_month.
   l_year = pa_spmon(4) - 1.
   concatenate l_year l_month into l_spmon.
endif.

if l_month1 ne 0.

   l_spmon1 = pa_spmon.
   do l_month1 times.
      l_count = l_count + 1.
      l_spmon1 = l_spmon1 - 1.
      loop at i_s603 where matnr eq i_outpl-matnr and vkbur eq
             i_outpl-werks and spmon eq l_spmon1.
        if l_count = 1.
          i_outpl-x1 = i_outpl-x1 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 2.
          i_outpl-x2 = i_outpl-x2 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 3.
          i_outpl-x3 = i_outpl-x3 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 4.
          i_outpl-x4 = i_outpl-x4 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 5.
          i_outpl-x5 = i_outpl-x5 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 6.
          i_outpl-x6 = i_outpl-x6 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
      endloop.

   enddo.
endif.
if l_month ne 0 and l_spmon(4) ne '2002'.

   l_spmon1 = l_spmon + ( 13 - l_month ).

   do l_month times.
      l_count = l_count + 1.
      l_spmon1 = l_spmon1 - 1.
      loop at i_s603 where matnr eq i_outpl-matnr and vkbur eq
             i_outpl-werks and spmon eq l_spmon1.
        if l_count = 1.
          i_outpl-x1 = i_outpl-x1 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 2.
          i_outpl-x2 = i_outpl-x2 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 3.
          i_outpl-x3 = i_outpl-x3 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 4.
          i_outpl-x4 = i_outpl-x4 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 5.
          i_outpl-x5 = i_outpl-x5 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.
        if l_count = 6.
          i_outpl-x6 = i_outpl-x6 + ( i_s603-ummenge + i_s603-gumenge ).
        endif.

      endloop.
   enddo.
elseif l_spmon(4) eq '2002'.
   clear *mver.
   select single * into *mver from mver where matnr eq i_outpl-matnr and
             werks eq i_outpl-werks and gjahr eq '2002'.
    l_spmon1 = l_spmon + ( 13 - l_month ).
    do l_month times.
        l_count = l_count + 1.
        l_spmon1 = l_spmon1 - 1.
        if l_spmon1 eq '200212'.
           l_qty = *mver-mgv12.
        elseif l_spmon1 eq '200211'.
           l_qty = *mver-mgv11.
        elseif l_spmon1 eq '200210'.
           l_qty = *mver-mgv10.
        elseif l_spmon1 eq '200209'.
           l_qty = *mver-mgv09.
        elseif l_spmon1 eq '200208'.
           l_qty = *mver-mgv08.
        elseif l_spmon1 eq '200207'.
           l_qty = *mver-mgv07.
        elseif l_spmon1 eq '200206'.
           l_qty = *mver-mgv06.
        elseif l_spmon1 eq '200205'.
           l_qty = *mver-mgv05.
        elseif l_spmon1 eq '200204'.
           l_qty = *mver-mgv04.
        elseif l_spmon1 eq '200203'.
           l_qty = *mver-mgv03.
        elseif l_spmon1 eq '200202'.
           l_qty = *mver-mgv02.
        elseif l_spmon1 eq '200201'.
           l_qty = *mver-mgv01.
        endif.
        if l_count = 1.
          i_outpl-x1 = i_outpl-x1 + l_qty.
        endif.
        if l_count = 2.
          i_outpl-x2 = i_outpl-x2 + l_qty.
        endif.
        if l_count = 3.
          i_outpl-x3 = i_outpl-x3 + l_qty.
        endif.
        if l_count = 4.
          i_outpl-x4 = i_outpl-x4 + l_qty.
        endif.
        if l_count = 5.
          i_outpl-x5 = i_outpl-x5 + l_qty.
        endif.
        if l_count = 6.
          i_outpl-x6 = i_outpl-x6 + l_qty.
        endif.

   enddo.

endif.
ENDFORM.                    " get_avrg
*&---------------------------------------------------------------------*
*&      Form  get_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  get_data1.
data : l_fl_proc like zsac7_tmp.

if pa_spmon+4(2) ne sy-datum+4(2).
   l_fl_proc = 'LC'.
else.
   l_fl_proc = 'CC'.
endif.
   select * into table i_outpl from zsac7_tmp where werks in so_plant
            and matnr in so_matnr and fl_proc eq l_fl_proc and
            PRODH1 in so_prodh.

ENDFORM.                    " get_data1

*&---------------------------------------------------------------------*
*&      Form  f_append_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_append_itab.

*Data : Percen like i_outpl-stratio.

*       clear : i_outpl-avqty, i_outpl-avamt, i_outpl-stratio.
*
*       if pa_month eq '1'.
*           i_outpl-avqty = ( i_outpl-x1 ) / pa_month.
*       elseif pa_month eq '2'.
*           i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 ) / pa_month.
*       elseif pa_month eq '3'.
*           i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 )
*                       / pa_month.
*       elseif pa_month eq '4'.
*           i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 ) / pa_month.
*       elseif pa_month eq '5'.
*           i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 + i_outpl-x5 ) / pa_month.
*       elseif pa_month eq '6'.
*           i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
*                   i_outpl-x4 + i_outpl-x5 + i_outpl-x6 ) / pa_month.
*       endif.
*
*       i_outpl-avamt = i_outpl-avqty * i_outpl-nsp.
*
*       if i_outpl-avqty ne 0.
*          i_outpl-stratio = i_outpl-bretl / i_outpl-avqty.
*       else.
*          i_outpl-stratio = 0.
*       endif.

*  Select single kausf from marc into i_outpl-kausf
*    Where matnr = i_outpl-matnr and werks = i_outpl-werks.
*
*  If i_outpl-avqty ne 0.
*    i_outpl-ratms = i_outpl-brems / i_outpl-avqty.
*  Else.
*    i_outpl-ratms = i_outpl-brems / 1.
*  Endif.
  i_outpl-qdocn_ip = i_outpl-qdo_ip - abs( i_outpl-qcn_ip ).
  i_outpl-vdocn_ip = i_outpl-vdo_ip - abs( i_outpl-vcn_ip ).
  i_outpl-stkdocn_ip =  abs( i_outpl-stkcn_ip ) - i_outpl-stkdo_ip.

*  If i_outpl-kausf = 0.
*    Percen = 0.
*  Else.
*    Percen = i_outpl-ratms / i_outpl-kausf * 100.
*  Endif.
*  clear: i_outpl-ratid.
*  If Percen le 25.
*     i_outpl-ratid = '@0W@'.
*  Elseif Percen le 75.
*     i_outpl-ratid = '@8R@'.
*  Elseif Percen gt 150.
*     i_outpl-ratid = '@8Q@'.
*  Endif.

  READ TABLE i_zplbc WITH KEY bukrs = '8070'
                              reswk = i_outpl-werks TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    CLEAR: i_outpl-ratid.
  ENDIF.

  append i_outpl.

ENDFORM.                    " f_append_itab

*&---------------------------------------------------------------------*
*&      Form  f_cek_aix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_cek_aix.
*  If sy-opsys = 'AIX'.
    If i_dataset-STKCN_IP+12(1) = ' ' or
       i_dataset-STKCN_IP+12(1) = '-'.
    Else.
      Replace i_dataset-STKCN_IP+12(1) with space
         into i_dataset-STKCN_IP.
    Endif.
    If i_dataset-ratms+12(1) = ' ' or
       i_dataset-ratms+12(1) = '-'.
    Else.
      Replace i_dataset-ratms+12(1) with space into i_dataset-ratms.
    Endif.
*  Endif.
endform.                    " f_cek_aix

*&---------------------------------------------------------------------*
*&      Form  cek_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form cek_auth.
  Data : l_werks like t001w-werks.
  If so_plant-low is initial and so_plant-high is initial.
     l_werks = '*'.
     Perform check_object using l_werks.
  Elseif not so_plant-low is initial and so_plant-high is initial.
     l_werks = so_plant-low.
     Perform check_object using l_werks.
  Else.
     Select werks from t001w into l_werks
       where werks in so_plant.
         Perform check_object using l_werks.
     Endselect.
  Endif.
endform.                    " cek_auth

*&---------------------------------------------------------------------*
*&      Form  check_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_WERKS  text
*----------------------------------------------------------------------*
form check_object using p_l_werks.
  AUTHORITY-CHECK OBJECT  'M_MSEG_WWA'
      ID 'WERKS' FIELD p_l_werks.
      IF SY-SUBRC NE 0.
        MESSAGE E002(ZZ) WITH
          'You have no authorization for Plant ' p_l_werks.
      ENDIF.
endform.                    " check_object

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_GET_DATA_SUT .
  DATA : l_filename(125) TYPE c,
         l_begdt TYPE dats,
         l_enddt TYPE dats.

  CLEAR itabline_sut. REFRESH itabline_sut.

  CASE 'X'.
    WHEN radio1.
      CONCATENATE pa_path2 pa_spmon '_C.txt' INTO l_filename.
    WHEN radio2.
      CONCATENATE pa_path2 pa_spmon '_N.txt' INTO l_filename.
    WHEN OTHERS.
  ENDCASE.

  OPEN DATASET l_filename FOR INPUT IN text mode ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET l_filename INTO wa_itabline_sut.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      APPEND wa_itabline_sut TO itabline_sut.
    ENDDO.
  ENDIF.
  CLOSE DATASET l_filename.

  CONCATENATE pa_spmon(6) '01' INTO l_begdt.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_begdt
    IMPORTING
      last_day_of_month = l_enddt.

  SELECT * INTO TABLE i_a890
    FROM a890 WHERE kappl EQ 'V'
                AND kschl EQ 'ZEXC'
                AND vkorg EQ '8020'
                AND datab BETWEEN l_begdt AND l_enddt.

  IF i_a890[] IS NOT INITIAL.
    LOOP AT i_a890.
      i_a890-werks = i_a890-kunnr+3(4).
      MODIFY i_a890 TRANSPORTING werks.
    ENDLOOP.

    SORT i_a890 BY werks.
    DELETE ADJACENT DUPLICATES FROM i_a890 COMPARING werks.

    SELECT * INTO TABLE i_zplbc
      FROM zplbc FOR ALL ENTRIES IN i_a890
      WHERE werks EQ i_a890-werks
        AND reswk NE space.
  ENDIF.
endform.                    " F_GET_DATA_SUT

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_PROSES_DATA_SUT .
  DATA : l_prodh1 LIKE t179-prodh,
         l_prodh2 LIKE t179-prodh,
         l_prodh3 LIKE t179-prodh,
         l_len TYPE i.

  LOOP AT itabline_sut INTO wa_itabline_sut.
    CLEAR: i_dataset,i_outpl.
    i_dataset = wa_itabline_sut.

    READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                werks = i_dataset-werks.
    IF sy-subrc EQ 0.
      PERFORM f_cek_aix.
      i_dataset-werks = i_zplbc-reswk.
      MOVE-CORRESPONDING i_dataset TO i_outpl.

      l_len = STRLEN( i_outpl-matnr ).
      CHECK l_len EQ 9.

      l_prodh1 = i_outpl-prodh1.
      CONCATENATE i_outpl-prodh1 i_outpl-prodh2 INTO l_prodh2.
      CONCATENATE i_outpl-prodh1 i_outpl-prodh2 i_outpl-prodh3 INTO
                  l_prodh3.

      IF i_outpl-werks IN so_plant AND i_outpl-matnr IN so_matnr AND
         l_prodh3 IN so_prodh.
        AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
             ID 'PRODH' FIELD i_outpl-prodh1.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        PERFORM f_append_itab_sut.
      ELSEIF i_outpl-werks IN so_plant AND i_outpl-matnr IN so_matnr AND
             l_prodh2 IN so_prodh.
        AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
             ID 'PRODH' FIELD i_outpl-prodh1.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        PERFORM f_append_itab_sut.
      ELSEIF i_outpl-werks IN so_plant AND i_outpl-matnr IN so_matnr AND
             l_prodh1 IN so_prodh.
        AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
             ID 'PRODH' FIELD i_outpl-prodh1.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
        PERFORM f_append_itab_sut.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR itabline_sut.
  REFRESH itabline_sut.
endform.                    " F_PROSES_DATA_SUT

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_ITAB_SUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_APPEND_ITAB_SUT .
  i_outpl-qdocn_ip = i_outpl-qdo_ip - ABS( i_outpl-qcn_ip ).
  i_outpl-vdocn_ip = i_outpl-vdo_ip - ABS( i_outpl-vcn_ip ).
  i_outpl-stkdocn_ip =  ABS( i_outpl-stkcn_ip ) - i_outpl-stkdo_ip.
*  i_outpl-varsls = i_outpl-estsls - i_outpl-netsamt.

  CLEAR: i_outpl-nsp,i_outpl-kausf,i_outpl-ratid.
  COLLECT i_outpl.
  gv_utd = abap_on.
endform.                    " F_APPEND_ITAB_SUT

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_AVERAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_HITUNG_AVERAGE .
  DATA: li_outpl LIKE i_outpl OCCURS 0 WITH HEADER LINE,
        l_year TYPE i,
        percen LIKE i_outpl-stratio.

  li_outpl[] = i_outpl[].
  SORT li_outpl BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_outpl COMPARING matnr.

  IF li_outpl[] IS NOT INITIAL.
    SELECT a~matnr a~prodh b~zeinr
      INTO TABLE i_matnr
      FROM mvke AS a JOIN mara AS b ON a~matnr EQ b~matnr
      FOR ALL ENTRIES IN li_outpl
      WHERE a~matnr EQ li_outpl-matnr AND
            a~vkorg EQ '8020'         AND
            a~vtweg EQ '10'           AND
            a~prodh IN so_prodh.   "and b~lvorm = space.
  ENDIF.

  SORT i_outpl BY matnr werks.
  SORT i_matnr BY matnr.

  LOOP AT i_outpl.
    READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                reswk = i_outpl-werks.
    IF sy-subrc = 0.

      IF i_outpl-peran IS INITIAL.
        CLEAR: i_matnr,l_year.
        READ TABLE i_matnr WITH KEY matnr = i_outpl-matnr BINARY SEARCH.
        IF sy-subrc = 0 AND i_matnr-zeinr NE space.
          CONCATENATE i_matnr-zeinr+6(4) i_matnr-zeinr+3(2) INTO i_outpl-zeinr.
          l_year = ( pa_spmon(4) - i_outpl-zeinr(4) ) * 12.
          i_outpl-peran = l_year + ( pa_spmon+4(2) - i_outpl-zeinr+4(2) ).
        ELSE.
          i_outpl-peran = 6.
        ENDIF.

        IF pa_spmon EQ sy-datum(6).
          i_outpl-peran = i_outpl-peran - 1.
        ENDIF.

        IF i_outpl-peran > 6.
          i_outpl-peran = 6.
        ENDIF.

        IF i_outpl-prodh1 = 'BHR'.
          IF i_outpl-peran > 5.
            i_outpl-peran = 5.
          ENDIF.
        ELSEIF i_outpl-prodh1 = 'RCH' OR
               i_outpl-prodh1 = 'PHR' OR
               i_outpl-prodh1 = 'AVT'.
          IF i_outpl-peran > 4.
            i_outpl-peran = 4.
          ENDIF.
        ELSEIF i_outpl-prodh1 = 'ALC' OR
             ( i_outpl-prodh1 = 'TSP' AND i_outpl-prodh2 = 'ELY' ).
          IF i_outpl-peran > 3.
            i_outpl-peran = 3.
          ENDIF.
        ENDIF.
      ENDIF.

      IF i_outpl-peran EQ 6.
        i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                          i_outpl-x4 + i_outpl-x5 + i_outpl-x6 ) /
                          i_outpl-peran.
      ELSEIF i_outpl-peran EQ 5.
        i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                          i_outpl-x4 + i_outpl-x5 ) /
                          i_outpl-peran.
      ELSEIF i_outpl-peran EQ 4.
        i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                          i_outpl-x4 ) /
                          i_outpl-peran.
      ELSEIF i_outpl-peran EQ 3.
        i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 ) /
                          i_outpl-peran.
      ELSEIF i_outpl-peran EQ 2.
        i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 ) /
                          i_outpl-peran.
      ELSEIF i_outpl-peran EQ 1.
        i_outpl-avqty = ( i_outpl-x1 ) / i_outpl-peran.
      ENDIF.

      i_outpl-avamt = i_outpl-avqty * i_outpl-nsp.
      i_outpl-doamt = i_outpl-nsp * i_outpl-bretl.

      IF i_outpl-avqty NE 0.
        i_outpl-stratio = i_outpl-bretl / i_outpl-avqty.
        i_outpl-ratms = i_outpl-brems / i_outpl-avqty.
      ELSE.
        i_outpl-stratio = 0.
        i_outpl-ratms = i_outpl-brems / 1.
      ENDIF.

      CLEAR: i_outpl-ratid, percen.
      IF i_outpl-kausf = 0.
        percen = 0.
      ELSE.
        percen = i_outpl-ratms / i_outpl-kausf * 100.
      ENDIF.
      IF percen LE 25.
        i_outpl-ratid = '@0W@'.
      ELSEIF percen LE 75.
        i_outpl-ratid = '@8R@'.
      ELSEIF percen GT 150.
        i_outpl-ratid = '@8Q@'.
      ELSE.
        i_outpl-ratid = '    '.
      ENDIF.

      MODIFY i_outpl TRANSPORTING zeinr peran avqty avamt doamt stratio ratms ratid.
    ENDIF.
  ENDLOOP.

  SORT i_outpl BY matnr.
endform.                    " F_HITUNG_AVERAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_DESC
*&---------------------------------------------------------------------*
form F_GET_MATERIAL_DESC .
  DATA: li_outpl LIKE i_outpl OCCURS 0 WITH HEADER LINE.

  IF i_outpl[] IS NOT INITIAL.
    li_outpl[] = i_outpl[].
    SORT li_outpl BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_outpl COMPARING matnr.

    SELECT * INTO TABLE gt_makt
      FROM makt FOR ALL ENTRIES IN li_outpl
      WHERE matnr EQ li_outpl-matnr
        AND spras EQ sy-langu.
  ENDIF.

  SORT i_outpl BY matnr.
  SORT gt_makt BY matnr.
  LOOP AT i_outpl ASSIGNING <fs_outpl>.
    CLEAR gt_makt.
    READ TABLE gt_makt WITH KEY matnr = <fs_outpl>-matnr BINARY SEARCH.
    <fs_outpl>-maktx = gt_makt-maktx.
  ENDLOOP.
endform.                    " F_GET_MATERIAL_DESC
