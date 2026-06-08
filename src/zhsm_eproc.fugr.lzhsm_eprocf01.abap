*----------------------------------------------------------------------*
***INCLUDE LZHSM_EPROCF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data USING   fu_quarter.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data TABLES ft_form01    STRUCTURE itcoo
                         ft_form02    STRUCTURE itcoo
                         ft_form03    STRUCTURE itcoo
                         ft_form04    STRUCTURE itcoo
                  USING fu_prgrp fu_dest fu_nodialog fu_tdnoprev
                        fu_preview fu_getoff.
  DATA : lv_vrsio   TYPE zgdmmt004z-vrsio.

  PERFORM f_create_header USING fu_prgrp
                          CHANGING lv_vrsio.
  PERFORM f_form_alokasi TABLES ft_form01
                         USING 'X' '' fu_tdnoprev fu_nodialog fu_preview
                               fu_getoff lv_vrsio fu_dest.
  PERFORM f_form_lampiran_po TABLES ft_form02
                             USING 'X' 'X' fu_tdnoprev fu_nodialog fu_preview
                                   fu_getoff lv_vrsio fu_dest.
  IF fu_prgrp IS INITIAL.
    PERFORM f_form_lampiran_alokasi TABLES ft_form03
                                    USING '' 'X' fu_tdnoprev fu_nodialog fu_preview
                                          fu_getoff lv_vrsio fu_dest.
  ELSE.
    IF gt_006[] IS NOT INITIAL.
      PERFORM f_form_lampiran_alokasi TABLES ft_form03
                                      USING 'X' 'X' fu_tdnoprev fu_nodialog
                                            fu_preview fu_getoff lv_vrsio fu_dest.
      PERFORM f_form_lampiran_prgrp TABLES ft_form04
                                    USING '' 'X' fu_tdnoprev fu_nodialog
                                          fu_preview fu_getoff lv_vrsio fu_dest.
    ELSE.
      PERFORM f_form_lampiran_alokasi TABLES ft_form03
                                      USING '' 'X' fu_tdnoprev fu_nodialog
                                            fu_preview fu_getoff lv_vrsio fu_dest.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FORM_ALOKASI
*&---------------------------------------------------------------------*
FORM f_form_alokasi  TABLES   ft_form   STRUCTURE itcoo
                     USING    fu_close fu_open fu_tdnoprev fu_nodialog
                              fu_preview fu_getotf fu_vrsio fu_dest.
  DATA : lv_tdform  TYPE ssfscreen-fname,
         ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop,
         lv_menget  LIKE eket-menge,
         lv_totpage TYPE i,
         lv_record  TYPE i,
         lv_lines   TYPE i,
         lv_times   TYPE i,
         lv_count   TYPE i,
         lv_div     TYPE i,
         lv_mod     TYPE i.

  DATA : x1 TYPE i,
         x2 TYPE i.

  DATA : lt_detail   TYPE STANDARD TABLE OF zgdmmst0052,
         lt_sub      TYPE STANDARD TABLE OF zgdmmst0052,
         lt_xsuppl   TYPE STANDARD TABLE OF zgdmmst002x,

         lt_nsupl    TYPE STANDARD TABLE OF zgdmmst0055,
         lt_004c     TYPE STANDARD TABLE OF zgdmmt004c,
         lt_supplier TYPE STANDARD TABLE OF zgdmmst0053,
         ls_supplier TYPE zgdmmst0053,
         ls_004c     LIKE LINE OF lt_004c.

  lv_tdform  = 'ZHSMMMSF0011'.
  PERFORM f_determine_smrt_funcmod USING lv_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_close     = fu_close.

  d_output_opt-tdnoprev     = fu_tdnoprev.
  d_output_opt-tddest       = fu_dest.
  d_ctrl_param-no_dialog    = fu_nodialog.
  d_ctrl_param-preview      = fu_preview.
  d_ctrl_param-getotf       = fu_getotf.

  lt_004c[] = gt_004c[].
  SORT lt_004c BY posnr lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_004c COMPARING posnr lifnr.
  DESCRIBE TABLE lt_004c LINES lv_record.
  lv_div  = lv_record DIV 3.
  lv_mod  = lv_record MOD 3.

  IF lv_mod <> 0.
    lv_times = lv_div + 1.
  ELSE.
    lv_times = lv_div.
  ENDIF.

  IF x1 IS INITIAL.
    x1 = 1.
    x2 = x1 + 2.
  ENDIF.

  DO lv_times TIMES.
    CLEAR lv_count.
    LOOP AT lt_004c INTO ls_004c FROM x1 TO x2.
      ADD 1 TO lv_count.
      CASE lv_count.
        WHEN 1.
          ls_supplier-lifnr1  = ls_004c-lifnr.
        WHEN 2.
          ls_supplier-lifnr2  = ls_004c-lifnr.
        WHEN 3.
          ls_supplier-lifnr3  = ls_004c-lifnr.
      ENDCASE.
    ENDLOOP.

    APPEND ls_supplier TO lt_supplier.
    CLEAR ls_supplier.

    x1 = x2 + 1.
    x2 = x1 + 2.
  ENDDO.

  DESCRIBE TABLE lt_supplier LINES lv_lines.

  LOOP AT lt_supplier INTO ls_supplier.
    PERFORM f_supplier_data TABLES lt_nsupl lt_sub
                            USING gs_quarter-year gs_quarter-q
                                  ls_supplier-lifnr1 ls_supplier-lifnr2
                                  ls_supplier-lifnr3.

    IF fu_open IS INITIAL AND
      fu_close IS INITIAL.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.
    ENDIF.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        t_header           = gs_header
        wa_supplier        = ls_supplier
        va_menget          = lv_menget
        va_record          = lv_record
        va_totpage         = lv_totpage
        va_lines           = lv_lines
      IMPORTING
        job_output_info    = ls_info
        job_output_options = ls_options
      TABLES
        t_detail           = lt_detail
        t_sub              = lt_sub
        t_suppl            = lt_xsuppl
        t_nsupl            = lt_nsupl.

    IF fu_open IS INITIAL AND
      fu_close IS INITIAL.
      d_ctrl_param-no_open = 'X'.
    ELSEIF lv_lines > 1.
      d_ctrl_param-no_open = 'X'.
    ENDIF.
  ENDLOOP.

  ft_form[] = ls_info-otfdata[].
  PERFORM f_send_pdf USING ls_info ls_options fu_vrsio.
ENDFORM.                    " F_FORM_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_SUPPLIER_DATA
*&---------------------------------------------------------------------*
FORM f_supplier_data  TABLES  ft_nsupl STRUCTURE zgdmmst0055
                              ft_sub   STRUCTURE zgdmmst0052
                      USING   fu_year fu_q
                              fu_lifnr1 fu_lifnr2 fu_lifnr3.

  DATA : lt_x004c TYPE STANDARD TABLE OF zgdmmt004c,
         ls_x004c LIKE LINE OF lt_x004c,
         ls_004c  LIKE LINE OF gt_004c,
         ls_004   LIKE LINE OF gt_004,
         ls_nsupl TYPE zgdmmst0055,
         ls_sub   TYPE zgdmmst0052,
         lt_x004y TYPE STANDARD TABLE OF zgdmmt004y,
         ls_x004y LIKE LINE OF lt_x004y.

  DATA : lv_quart,
         lv_q1,
         lv_q2,
         lv_q3,
         lv_q4,
         lv_semester,
         lv_menge      TYPE eban-menge,
         lv_menget(17).

  CLEAR : ft_nsupl[].

  lt_x004c[] = gt_004c[].
  SORT lt_x004c BY zeile.
  DELETE ADJACENT DUPLICATES FROM lt_x004c COMPARING zeile.

  CASE fu_q.
    WHEN '1'.
      lv_quart    = '1'.
      lv_q1       = '1'.
      lv_semester = '1'.
    WHEN '2'.
      lv_quart    = '2'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_semester = '1'.
    WHEN '3'.
      lv_quart    = '3'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_semester = '2'.
    WHEN '4'.
      lv_quart    = '4'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_q4       = '4'.
      lv_semester = '2'.
  ENDCASE.

  LOOP AT lt_x004c INTO ls_x004c.
    READ TABLE gt_004 INTO ls_004
                      WITH KEY zeile = ls_x004c-zeile.
    IF sy-subrc = 0.
      ls_nsupl-zeile       = ls_004-zeile.
      ls_nsupl-nou         = ls_004-nou.
      ls_nsupl-keterangan  = ls_004-description.
      CASE ls_004-period.
        WHEN 'S'.
          REPLACE ALL OCCURRENCES OF REGEX '&1' IN ls_nsupl-keterangan WITH lv_semester.
        WHEN 'Q'.
          IF ls_004-zgroup1 IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF REGEX '&1' IN ls_nsupl-keterangan WITH lv_q1.
            REPLACE ALL OCCURRENCES OF REGEX '&2' IN ls_nsupl-keterangan WITH lv_q2.
            REPLACE ALL OCCURRENCES OF REGEX '&3' IN ls_nsupl-keterangan WITH lv_q3.
            REPLACE ALL OCCURRENCES OF REGEX '&4' IN ls_nsupl-keterangan WITH lv_q4.
          ELSE.
            REPLACE ALL OCCURRENCES OF REGEX '&1' IN ls_nsupl-keterangan WITH lv_quart.
          ENDIF.
      ENDCASE.
      REPLACE ALL OCCURRENCES OF REGEX '&y' IN ls_nsupl-keterangan WITH fu_year.
      ls_nsupl-zend        = ls_004-zend.

      LOOP AT gt_004c INTO ls_004c WHERE zeile = ls_x004c-zeile.
        CASE ls_004c-lifnr.
          WHEN fu_lifnr1.
            ls_nsupl-csupl1      = ls_004c-value.
          WHEN fu_lifnr2.
            ls_nsupl-csupl2      = ls_004c-value.
          WHEN fu_lifnr3.
            ls_nsupl-csupl3      = ls_004c-value.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    APPEND ls_nsupl TO ft_nsupl.
    CLEAR ls_nsupl.
  ENDLOOP.

  lt_x004y[] = gt_004y[].
  SORT lt_x004y BY banfn bnfpo.
  DELETE ADJACENT DUPLICATES FROM lt_x004y COMPARING banfn bnfpo.
  LOOP AT lt_x004y INTO ls_x004y.
    ADD ls_x004y-menge TO lv_menge.
  ENDLOOP.

  WRITE lv_menge TO lv_menget DECIMALS 3.
  SPLIT lv_menget AT ',' INTO ls_sub-menget ls_sub-decimal.
  CONDENSE ls_sub-menget NO-GAPS.
  CONDENSE ls_sub-decimal NO-GAPS.
  APPEND ls_sub TO ft_sub.
ENDFORM.                    " F_SUPPLIER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  USING    fs_004z       TYPE zgdmmt004z
                        fu_prgrp.
  DATA : lv_peinh(20),
         lv_bprme(10),
         lv_ppeinh(20),
         lv_pprme(10).

  MOVE-CORRESPONDING fs_004z TO gs_header.

  gs_header-prgrp    = fu_prgrp.
  gs_header-gjahr    = fs_004z-zaldt(4).

  SELECT SINGLE maktx
    FROM makt
    INTO gs_header-maktx
    WHERE matnr = gs_header-matnr.

* Budget Price
  WRITE fs_004z-kbetr TO gs_header-budget CURRENCY fs_004z-konwa.
  CONDENSE gs_header-budget NO-GAPS.

* High Price
  WRITE fs_004z-highp TO gs_header-hight CURRENCY fs_004z-pwaer.
  CONDENSE gs_header-hight NO-GAPS.
  IF fs_004z-ppeinh IS NOT INITIAL.
    lv_ppeinh = fs_004z-ppeinh.
    CONDENSE lv_ppeinh.
    PERFORM f_meins_conversion USING fs_004z-pprme
                               CHANGING lv_pprme.
    CONCATENATE gs_header-hight '/' lv_ppeinh lv_pprme
    INTO gs_header-hight
    SEPARATED BY space.
  ENDIF.

* Last Purchased
  gs_header-datlb   = fs_004z-bedat.
  WRITE fs_004z-preis TO gs_header-netprt CURRENCY fs_004z-bwaer.
  CONDENSE gs_header-netprt NO-GAPS.

  lv_peinh  = fs_004z-peinh.
  CONDENSE lv_peinh NO-GAPS.
  PERFORM f_meins_conversion USING fs_004z-bprme
                             CHANGING lv_bprme.
  CONCATENATE gs_header-netprt '/' lv_peinh lv_bprme
  INTO gs_header-netprt
  SEPARATED BY space.

  gs_header-waers = fs_004z-bwaer.

  WRITE fs_004z-menge TO gs_header-menget UNIT fs_004z-meins.
  CONDENSE gs_header-menget.
  PERFORM f_meins_conversion USING fs_004z-meins
                             CHANGING gs_header-meinst.

  SELECT SINGLE name1
    FROM lfa1
    INTO gs_header-name1
    WHERE lifnr = fs_004z-lifnr.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_MEINS_CONVERSION
*&---------------------------------------------------------------------*
FORM f_meins_conversion  USING   fu_meins
                         CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_MEINS_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_SIGNATURE
*&---------------------------------------------------------------------*
FORM f_signature  USING    fs_004z       TYPE zgdmmt004z.
  DATA : lt_005           TYPE STANDARD TABLE OF zhsmmmdt005,
         ls_005           LIKE LINE OF lt_005,
         lv_objectclass   TYPE cdhdr-objectclas,
         lv_id            TYPE cdhdr-objectid,
         editpos          TYPE STANDARD TABLE OF cdred,
         ls_editpos       LIKE LINE OF editpos,
         lv_fieldname(30),
         lv_approved(30),
         lv_srno2         TYPE zhsmmmdt005-srno1,
         lv_subrc         TYPE sy-subrc,
         lv_srno1(2).

  FIELD-SYMBOLS : <fs>   TYPE any,
                  <fs_x> TYPE any.

  lv_approved     = 'APPROVED'.
  lv_objectclass  = 'EPROC_APPR'.
  lv_id           = fs_004z-zalno.

  IF lv_id IS NOT INITIAL.
    CALL FUNCTION 'CHANGEDOCUMENT_READ'
      EXPORTING
        objectclass                = lv_objectclass
        objectid                   = lv_id
      TABLES
        editpos                    = editpos
      EXCEPTIONS
        no_position_found          = 1
        wrong_access_to_archive    = 2
        time_zone_conversion_error = 3
        OTHERS                     = 4.

    IF sy-subrc = 0.
      SORT editpos BY changenr udate utime.
    ENDIF.
  ENDIF.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE lt_005
    WHERE tcode = 'ZMME013'
      AND ekgrp = fs_004z-ekgrp.

  IF fs_004z-frgco IS NOT INITIAL.
    lv_subrc = 4.
    SORT lt_005 BY srno1.
    LOOP AT lt_005 INTO ls_005.
      IF ls_005-srno1 = '000' OR
        ls_005-srno1 = '001'.
        CONTINUE.
      ENDIF.
      lv_srno2  = ls_005-srno1 - 1.
      CONCATENATE 'GS_HEADER-SIGN' lv_srno2 INTO lv_fieldname.
      ASSIGN (lv_fieldname) TO <fs>.
      <fs> = lv_approved.

      CLEAR ls_editpos.
      READ TABLE editpos INTO ls_editpos
                         WITH KEY f_new = ls_005-frgco.
      IF sy-subrc = 0.
        CONCATENATE 'GS_HEADER-DATE' lv_srno2 INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        <fs> = ls_editpos-udate.
      ENDIF.

      IF ls_005-frgco = fs_004z-frgco.
        CLEAR lv_subrc.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_subrc <> 0.
      LOOP AT lt_005 INTO ls_005.
        CONCATENATE 'GS_HEADER-SIGN' ls_005-srno1 INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        <fs> = space.
        CONCATENATE 'GS_HEADER-DATE' ls_005-srno1 INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs>.
        <fs> = space.
      ENDLOOP.
    ENDIF.

    SORT lt_005 BY srno1.
    DELETE ADJACENT DUPLICATES FROM lt_005 COMPARING srno1.
    LOOP AT lt_005 INTO ls_005.
      IF ls_005-srno1 = '000'.
        CONTINUE.
      ENDIF.
      IF ls_005-smtp_addr IS NOT INITIAL.
        lv_srno1 = ls_005-srno1+1(2).
        CONCATENATE 'GS_HEADER-XSIGN' lv_srno1 INTO lv_fieldname.
        ASSIGN (lv_fieldname) TO <fs_x>.
        <fs_x> = 'X'.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SIGNATURE

*&---------------------------------------------------------------------*
*&      Form  F_FORM_LAMPIRAN_PO
*&---------------------------------------------------------------------*
FORM f_form_lampiran_po  TABLES   ft_form   STRUCTURE itcoo
                         USING    fu_close fu_open fu_tdnoprev fu_nodialog
                                  fu_preview fu_getotf fu_vrsio fu_dest.
  DATA : lv_tdform  TYPE ssfscreen-fname,
         ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop,
         lv_menget  LIKE eket-menge,
         lv_record  TYPE i,
         lv_totpage TYPE i,
         lv_lines   TYPE i,
         lt_detail  TYPE STANDARD TABLE OF zgdmmst0052,
         lt_sub     TYPE STANDARD TABLE OF zgdmmst0052,
         lt_lampo   TYPE STANDARD TABLE OF zgdmmst0052.

  DATA : ls_004z  LIKE LINE OF gt_004z,
         ls_lampo LIKE LINE OF lt_lampo.

  lv_tdform  = 'ZHSMMMSF0013'.
  PERFORM f_determine_smrt_funcmod USING lv_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open      = fu_open.
  d_ctrl_param-no_close     = fu_close.

  d_output_opt-tdnoprev     = fu_tdnoprev.
  d_output_opt-tddest       = fu_dest.
  d_ctrl_param-no_dialog    = fu_nodialog.
  d_ctrl_param-preview      = fu_preview.
  d_ctrl_param-getotf       = fu_getotf.

  READ TABLE gt_004z INTO ls_004z INDEX 1.

  PERFORM f_get_purchase_order TABLES lt_lampo
                               USING ls_004z-zaldt ls_004z-ekgrp
                                     ls_004z-werks ls_004z-matnr.

  LOOP AT lt_lampo INTO ls_lampo.
    ADD ls_lampo-menge  TO lv_menget.
  ENDLOOP.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
      va_menget          = lv_menget
      va_record          = lv_record
      va_totpage         = lv_totpage
      va_lines           = lv_lines
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      t_detail           = lt_detail
      t_sub              = lt_sub
      t_lfa1             = gt_lfa1
      t_lampo            = lt_lampo.

  IF fu_open IS INITIAL AND
    fu_close IS INITIAL.
    d_ctrl_param-no_open = 'X'.
  ELSEIF lv_lines > 1.
    d_ctrl_param-no_open = 'X'.
  ENDIF.

  ft_form[] = ls_info-otfdata[].
  PERFORM f_send_pdf USING ls_info ls_options fu_vrsio.
ENDFORM.                    " F_FORM_LAMPIRAN_PO

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HEADER
*&---------------------------------------------------------------------*
FORM f_create_header USING     fu_prgrp
                     CHANGING  fc_vrsio.

  DATA : ls_004z    LIKE LINE OF gt_004z.

  CLEAR : gs_header.

  READ TABLE gt_004z INTO ls_004z INDEX 1.

  PERFORM f_header USING ls_004z fu_prgrp.

  PERFORM f_signature USING ls_004z.

  fc_vrsio = ls_004z-vrsio.

ENDFORM.                    " F_CREATE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_FORM_LAMPIRAN_ALOKASI
*&---------------------------------------------------------------------*
FORM f_form_lampiran_alokasi  TABLES   ft_form   STRUCTURE itcoo
                              USING    fu_close fu_open fu_tdnoprev fu_nodialog
                                       fu_preview fu_getotf fu_vrsio fu_dest.
  DATA : lv_tdform  TYPE ssfscreen-fname,
         ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop,
         lt_heads   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_detls   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_texts   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_total   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_xsuppl  TYPE STANDARD TABLE OF zgdmmst002x,
         lt_lfa1    TYPE STANDARD TABLE OF ty_lfa1,
         lt_x004y   TYPE STANDARD TABLE OF zgdmmt004y,
         ls_x004y   LIKE LINE OF lt_x004y,
         ls_004y    LIKE LINE OF gt_004y,
         ls_004c    LIKE LINE OF gt_004c,
         ls_004z    LIKE LINE OF gt_004z,
         ls_heads   LIKE LINE OF lt_heads,
         ls_detls   LIKE LINE OF lt_detls,
         ls_lfa1    LIKE LINE OF gt_lfa1,
         lv_percen  TYPE konp-kbetr,
         lv_total   TYPE ekpo-menge,
         lv_menge   TYPE ekpo-menge,
         lv_zeile   TYPE zgdmmt0004x-zeile,
         lv_tdname  TYPE thead-tdname,
         lt_text    TYPE STANDARD TABLE OF ty_text,
         ls_text    LIKE LINE OF lt_text,
         ls_texts   LIKE LINE OF gt_texts.

  lv_tdform  = 'ZHSMMMSF002'.
  PERFORM f_determine_smrt_funcmod USING lv_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open      = fu_open.
  d_ctrl_param-no_close     = fu_close.

  d_output_opt-tdnoprev     = fu_tdnoprev.
  d_output_opt-tddest       = fu_dest.
  d_ctrl_param-no_dialog    = fu_nodialog.
  d_ctrl_param-preview      = fu_preview.
  d_ctrl_param-getotf       = fu_getotf.

  READ TABLE gt_004z INTO ls_004z INDEX 1.

  lt_x004y[] = gt_004y[].
  SORT lt_x004y BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x004y COMPARING lifnr.
  LOOP AT lt_x004y INTO ls_x004y.
    ls_heads-lifnr    = ls_x004y-lifnr.
    CLEAR ls_lfa1.
    READ TABLE gt_lfa1 INTO ls_lfa1
                       WITH KEY lifnr = ls_x004y-lifnr.
    IF sy-subrc = 0.
      ls_heads-name1   = ls_lfa1-name1.
    ENDIF.
    ls_heads-meins    = ls_x004y-meins.

    LOOP AT gt_004y INTO ls_004y WHERE lifnr = ls_x004y-lifnr.
      ls_detls-lifnr  = ls_004y-lifnr.
      ls_detls-banfn  = ls_004y-banfn.
      ls_detls-eindt  = ls_004y-lfdat.
      ls_detls-menge  = ls_004y-menge.
      ls_detls-meins  = ls_004y-meins.
      WRITE ls_detls-menge TO ls_detls-menget UNIT ls_detls-meins.
      CONDENSE ls_detls-menget NO-GAPS.
      WRITE ls_004y-bsmng TO ls_detls-alloct UNIT ls_detls-meins.
      CONDENSE ls_detls-alloct NO-GAPS.
      lv_percen = ( ls_004y-bsmng / ls_detls-menge ) * 100.
      WRITE lv_percen TO ls_detls-kbetrt DECIMALS 2.
      CONDENSE ls_detls-kbetrt NO-GAPS.

      ADD ls_004y-bsmng TO lv_total.
      ADD ls_004y-menge TO lv_menge.

      APPEND ls_detls TO lt_detls.
      CLEAR ls_detls.
    ENDLOOP.

    CONCATENATE ls_004z-submi ls_004z-zalno ls_004z-vrsio ls_x004y-lifnr INTO lv_tdname.
    PERFORM f_read_text TABLES lt_text
                        USING  lv_tdname.
    LOOP AT lt_text INTO ls_text.
      ls_texts-lifnr    = ls_heads-lifnr.
      ls_texts-lines    = ls_text-line.
      APPEND ls_texts TO gt_texts.
      CLEAR : ls_texts.
    ENDLOOP.
    CLEAR lt_text[].

    WRITE lv_total TO ls_heads-totalt UNIT ls_heads-meins.
    CONDENSE ls_heads-totalt NO-GAPS.
    lv_percen = ( lv_total / lv_menge ) * 100.
    WRITE lv_percen TO ls_heads-kbetrt DECIMALS 2.
    CONDENSE ls_heads-kbetrt NO-GAPS.
    WRITE lv_menge TO ls_heads-menget UNIT ls_heads-meins.
    CONDENSE ls_heads-menget NO-GAPS.

    CLEAR ls_004c.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY lifnr = ls_heads-lifnr
                                zeile = 18.
    IF sy-subrc = 0.
      ls_heads-preist = ls_004c-value.
    ENDIF.

    CASE gs_quarter-q.
      WHEN 1.
        lv_zeile  = 10.
      WHEN 2.
        lv_zeile  = 11.
      WHEN 3.
        lv_zeile  = 12.
      WHEN 4.
        lv_zeile  = 13.
    ENDCASE.

    CLEAR ls_004c.
    READ TABLE gt_004c INTO ls_004c
                       WITH KEY lifnr = ls_heads-lifnr
                                zeile = lv_zeile.
    IF sy-subrc = 0.
      ls_heads-percen = gs_quarter-q.
      CONDENSE ls_heads-percen NO-GAPS.
      CONCATENATE 'Q' ls_heads-percen INTO ls_heads-percen.
      CONCATENATE ls_heads-percen ':' ls_004c-value INTO ls_heads-percen
      SEPARATED BY space.
    ENDIF.
    APPEND ls_heads TO lt_heads.
    CLEAR : ls_heads, lv_menge, lv_total.
  ENDLOOP.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      gt_heads           = lt_heads
      gt_detls           = lt_detls
      gt_texts           = gt_texts
      gt_lfa1            = lt_lfa1
      gt_total           = lt_total
      gt_xsuppl          = lt_xsuppl.

  ft_form[] = ls_info-otfdata[].
  PERFORM f_send_pdf USING ls_info ls_options fu_vrsio.

  CLEAR : gt_texts[].
ENDFORM.                    " F_FORM_LAMPIRAN_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_FORM_LAMPIRAN_PRGRP
*&---------------------------------------------------------------------*
FORM f_form_lampiran_prgrp  TABLES   ft_form   STRUCTURE itcoo
                            USING    fu_close fu_open fu_tdnoprev fu_nodialog
                                     fu_preview fu_getotf fu_vrsio fu_dest.
  DATA : lv_tdform  TYPE ssfscreen-fname,
         ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop,
         lt_heads   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_detls   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_texts   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_total   TYPE STANDARD TABLE OF zgdmmst0056,
         lt_lfa1    TYPE STANDARD TABLE OF ty_lfa1.

  lv_tdform  = 'ZHSMMMSF003'.
  PERFORM f_determine_smrt_funcmod USING lv_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open      = fu_open.
  d_ctrl_param-no_close     = fu_close.

  d_output_opt-tdnoprev     = fu_tdnoprev.
  d_output_opt-tddest       = fu_dest.
  d_ctrl_param-no_dialog    = fu_nodialog.
  d_ctrl_param-preview      = fu_preview.
  d_ctrl_param-getotf       = fu_getotf.

  PERFORM f_prepare_detail TABLES lt_lfa1 lt_total.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      gt_heads           = lt_heads
      gt_detls           = lt_detls
      gt_texts           = lt_texts
      gt_lfa1            = lt_lfa1
      gt_total           = lt_total.

  ft_form[] = ls_info-otfdata[].
  PERFORM f_send_pdf USING ls_info ls_options fu_vrsio.
ENDFORM.                    " F_FORM_LAMPIRAN_PRGRP

*&---------------------------------------------------------------------*
*&      Form  F_GET_PURCHASE_ORDER
*&---------------------------------------------------------------------*
FORM f_get_purchase_order TABLES  ft_lampo     STRUCTURE zgdmmst0052
                          USING   fu_zaldt fu_ekgrp fu_werks fu_matnr.
  DATA : lr_datum     TYPE RANGE OF sy-datum,
         ls_datum     LIKE LINE OF lr_datum,
         lr_bsart     TYPE RANGE OF bsart,
         ls_bsart     LIKE LINE OF lr_bsart,
         lt_ekko      TYPE STANDARD TABLE OF ekko,
         lt_ekpo      TYPE STANDARD TABLE OF ekpo,
         lt_xekpo     TYPE STANDARD TABLE OF ekpo,
         ls_ekko      LIKE LINE OF lt_ekko,
         ls_ekpo      LIKE LINE OF lt_ekpo,
         lt_004x      TYPE STANDARD TABLE OF zgdmmt004x,
         ls_004x      LIKE LINE OF lt_004x,
         lt_004y      TYPE STANDARD TABLE OF zgdmmt004y,
         ls_004y      LIKE LINE OF lt_004y,
         lt_004z      TYPE STANDARD TABLE OF zgdmmt004z,
         ls_004z      LIKE LINE OF lt_004z,
         ls_lampo     TYPE zgdmmst0052,
         lv_menge(20),
         lv_etmen     TYPE zgdmmt004x-etmen.

  CASE gs_quarter-q.
    WHEN 1.
      CONCATENATE fu_zaldt(4) '0101' INTO ls_datum-low.
      CONCATENATE fu_zaldt(4) '0331' INTO ls_datum-high.
    WHEN 2.
      CONCATENATE fu_zaldt(4) '0401' INTO ls_datum-low.
      CONCATENATE fu_zaldt(4) '0630' INTO ls_datum-high.
    WHEN 3.
      CONCATENATE fu_zaldt(4) '0701' INTO ls_datum-low.
      CONCATENATE fu_zaldt(4) '0930' INTO ls_datum-high.
    WHEN 4.
      CONCATENATE fu_zaldt(4) '1001' INTO ls_datum-low.
      CONCATENATE fu_zaldt(4) '1231' INTO ls_datum-high.
  ENDCASE.
  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.

  ls_bsart-low    = 'ZIMP'.
  ls_bsart-sign   = 'I'.
  ls_bsart-option = 'EQ'.
  APPEND ls_bsart TO lr_bsart.
  CLEAR ls_bsart.
  ls_bsart-low    = 'ZLOC'.
  ls_bsart-sign   = 'I'.
  ls_bsart-option = 'EQ'.
  APPEND ls_bsart TO lr_bsart.
  CLEAR ls_bsart.

  IF gt_lfa1[] IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE lt_ekko
      FOR ALL ENTRIES IN gt_lfa1
      WHERE lifnr = gt_lfa1-lifnr
        AND ekorg = 'TNT'
        AND ekgrp = fu_ekgrp
        AND aedat IN lr_datum
        AND bsart IN lr_bsart
        AND loekz = space
        AND autlf = space.

    IF lt_ekko[] IS NOT INITIAL.
      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
        FOR ALL ENTRIES IN lt_ekko
        WHERE ebeln = lt_ekko-ebeln
          AND loekz = space
          AND werks = fu_werks
          AND matnr = fu_matnr.
    ENDIF.

    lt_xekpo[] = lt_ekpo[].
    SORT lt_xekpo BY bednr.
    DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING bednr.
    DELETE lt_xekpo WHERE bednr = space.
    IF lt_xekpo[] IS NOT INITIAL.
      SELECT *
        FROM zgdmmt004z
        INTO CORRESPONDING FIELDS OF TABLE lt_004z
        FOR ALL ENTRIES IN lt_xekpo
        WHERE zalno = lt_xekpo-bednr.
      IF lt_004z[] IS NOT INITIAL.
        SELECT *
          FROM zgdmmt004x
          INTO CORRESPONDING FIELDS OF TABLE lt_004x
          FOR ALL ENTRIES IN lt_004z
          WHERE zalno = lt_004z-zalno.
        SELECT *
          FROM zgdmmt004y
          INTO CORRESPONDING FIELDS OF TABLE lt_004y
          FOR ALL ENTRIES IN lt_004z
          WHERE zalno = lt_004z-zalno.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT lt_ekko INTO ls_ekko.
    ls_lampo-lifnr  = ls_ekko-lifnr.
    ls_lampo-ebeln  = ls_ekko-ebeln.
    CLEAR : ls_ekpo, lv_menge.
    READ TABLE lt_ekpo INTO ls_ekpo
                       WITH KEY ebeln = ls_ekko-ebeln.
    IF sy-subrc = 0.
      CLEAR ls_004z.
      READ TABLE lt_004z INTO ls_004z
                         WITH KEY zalno = ls_ekpo-bednr.
      IF sy-subrc = 0.
        ls_lampo-submi  = ls_004z-submi.
      ENDIF.
      ls_lampo-menge  = ls_ekpo-menge.
      WRITE ls_ekpo-menge TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-menget ls_lampo-decim1.
      ls_lampo-meins  = ls_ekpo-meins.

      CLEAR : ls_004x, lv_etmen.
      LOOP AT lt_004x INTO ls_004x WHERE zalno = ls_ekpo-bednr
                                     AND lifnr = ls_ekko-lifnr
                                     AND matnr = ls_ekpo-matnr.
        ADD ls_004x-etmen TO lv_etmen.
      ENDLOOP.
      ls_lampo-bsmng  = lv_etmen.
      WRITE lv_etmen TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-etment ls_lampo-decim2.
      CLEAR ls_004y.
      READ TABLE lt_004y INTO ls_004y
                         WITH KEY zalno = ls_ekpo-bednr
                                  lifnr = ls_ekko-lifnr.
      IF sy-subrc = 0.
        ls_lampo-lfdat  = ls_004y-lfdat.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.

    APPEND ls_lampo TO ft_lampo.
    CLEAR ls_lampo.
  ENDLOOP.
ENDFORM.                    " F_GET_PURCHASE_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data  TABLES   ft_006 STRUCTURE zhsmmmdt006
                          ft_007 STRUCTURE zhsmmmdt007
                 USING    fu_filename fu_prgrp fu_submi fu_zalno
                 CHANGING fc_subrc.

  TYPES : BEGIN OF ty_lfa1,
            lifnr TYPE lfa1-lifnr,
            netpr TYPE ekpo-netpr,
            waers TYPE ekko-waers,
            bprme TYPE zhsmmmdt007-bprme,
            peinh TYPE eban-peinh,
            col01 TYPE alsmex_tabline-col,
            col02 TYPE alsmex_tabline-col,
            col03 TYPE alsmex_tabline-col,
          END OF ty_lfa1.

  TYPES : BEGIN OF ty_excel,
            row   LIKE alsmex_tabline-row,
            col   LIKE alsmex_tabline-col,
            value LIKE alsmex_tabline-value,
          END OF ty_excel.

  DATA : lt_excel TYPE STANDARD TABLE OF ty_excel,
         ls_excel LIKE LINE OF lt_excel,
         lt_lfa1  TYPE STANDARD TABLE OF ty_lfa1,
         ls_lfa1  LIKE LINE OF lt_lfa1,
         lt_x006  TYPE STANDARD TABLE OF zhsmmmdt006,
         lt_x007  TYPE STANDARD TABLE OF zhsmmmdt007,
         ls_006   TYPE zhsmmmdt006,
         ls_007   TYPE zhsmmmdt007,
         ls_x006  LIKE LINE OF lt_x006,
         ls_x007  LIKE LINE OF lt_x007.

  DATA : lv_matnr     TYPE mara-matnr,
         lv_maktx     TYPE makt-maktx,
         lv_index     TYPE i,
         lv_char1(50),
         lv_char2(50),
         lv_lifnr     TYPE lfa1-lifnr,
         lv_count     TYPE i,
         lv_zeile     TYPE mseg-zeile.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = fu_filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT lt_excel BY row col.
  LOOP AT lt_excel INTO ls_excel.
    CASE ls_excel-row.
      WHEN 1.
        IF ls_excel-col = 2.
          IF ls_excel-value <> fu_prgrp.
            fc_subrc = 1.
            EXIT.
          ENDIF.
        ENDIF.
        CONTINUE.
      WHEN 3.
        PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT007' 'LIFNR'
                             CHANGING ls_lfa1-lifnr.
        ls_lfa1-col01 = ls_excel-col.
        ls_lfa1-col02 = ls_excel-col + 1.
        ls_lfa1-col03 = ls_excel-col + 2.
        APPEND ls_lfa1 TO lt_lfa1.
        CLEAR ls_lfa1.
        CONTINUE.
      WHEN 4.
        ADD 1 TO lv_index.
        SPLIT ls_excel-value AT space INTO lv_char1 lv_char2.
        IF lv_char1 = 'Rp'.
          ls_lfa1-waers = 'IDR'.
        ELSE.
          ls_lfa1-waers = lv_char1.
        ENDIF.
        SPLIT lv_char2 AT '/' INTO lv_char1 lv_char2.
        PERFORM f_conversion USING lv_char1 ls_lfa1-waers 'ZHSMMMDT007' 'NETPR'
                             CHANGING ls_lfa1-netpr.
        PERFORM f_conversion USING lv_char2 '' 'ZHSMMMDT007' 'BPRME'
                             CHANGING ls_lfa1-bprme.
        ls_lfa1-peinh = 1.
        MODIFY lt_lfa1 FROM ls_lfa1
                       INDEX lv_index
                       TRANSPORTING waers netpr bprme peinh.
        CLEAR ls_lfa1.
        CONTINUE.
      WHEN 5.
        CONTINUE.
      WHEN OTHERS.
        CASE ls_excel-col.
          WHEN 1.
            IF ls_excel-value IS NOT INITIAL.
              lv_matnr     = ls_excel-value.
            ENDIF.
            ls_006-matnr = lv_matnr.
          WHEN 2.
            lv_maktx = ls_excel-value.
          WHEN 3.
            ls_006-banfn = ls_excel-value.
          WHEN 4.
            PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT006' 'BAMNG'
                                 CHANGING ls_006-bamng.
          WHEN 5.
            PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT006' 'BAMEI'
                                 CHANGING ls_006-bamei.
          WHEN 6.
            PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT006' 'LFDAT'
                                 CHANGING ls_006-lfdat.
          WHEN OTHERS.
            ADD 1 TO lv_count.
            CLEAR ls_lfa1.
            READ TABLE lt_lfa1 INTO ls_lfa1
                               WITH KEY col01 = ls_excel-col.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING ls_lfa1 TO ls_007.
              ls_007-ebeln  = ls_excel-value.
            ELSE.
              CLEAR ls_lfa1.
              READ TABLE lt_lfa1 INTO ls_lfa1
                                 WITH KEY col02 = ls_excel-col.
              IF sy-subrc = 0.
                MOVE-CORRESPONDING ls_lfa1 TO ls_007.
                PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT007' 'BEDAT'
                                     CHANGING ls_007-bedat.
              ELSE.
                CLEAR ls_lfa1.
                READ TABLE lt_lfa1 INTO ls_lfa1
                                   WITH KEY col03 = ls_excel-col.
                IF sy-subrc = 0.
                  MOVE-CORRESPONDING ls_lfa1 TO ls_007.
                  PERFORM f_conversion USING ls_excel-value '' 'ZHSMMMDT007' 'BSTMG'
                                       CHANGING ls_007-bstmg.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_count = 3.
              ls_007-prgrp    = fu_prgrp.
              ls_007-submi    = fu_submi.
              ls_007-zalno    = fu_zalno.
              IF ls_007-matnr IS INITIAL.
                ls_007-matnr = lv_matnr.
              ENDIF.
              ls_007-bstme    = ls_006-bamei.
              APPEND ls_007 TO ft_007.
              CLEAR : ls_007, lv_count.
            ENDIF.
        ENDCASE.
    ENDCASE.

    AT END OF row.
      ls_006-prgrp    = fu_prgrp.
      ls_006-submi    = fu_submi.
      ls_006-zalno    = fu_zalno.
      IF ls_006-matnr IS INITIAL.
        ls_006-matnr = lv_matnr.
      ENDIF.
      APPEND ls_006 TO ft_006.
      CLEAR : ls_006.
    ENDAT.
  ENDLOOP.

  SORT ft_006 BY matnr banfn.
  lt_x006[] = ft_006[].
  DELETE ADJACENT DUPLICATES FROM lt_x006 COMPARING matnr banfn.
  LOOP AT lt_x006 INTO ls_x006.
    CLEAR lv_zeile.
    LOOP AT ft_006 INTO ls_006 WHERE matnr = ls_x006-matnr
                                 AND banfn = ls_x006-banfn.
      ADD 1 TO lv_zeile.
      ls_006-zeile  = lv_zeile.
      MODIFY ft_006 FROM ls_006 TRANSPORTING zeile.
      CLEAR ls_006.
    ENDLOOP.
  ENDLOOP.

  SORT ft_007 BY matnr lifnr ebeln.
  lt_x007[] = ft_007[].
  DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING matnr lifnr ebeln.
  LOOP AT lt_x007 INTO ls_x007.
    CLEAR lv_zeile.
    LOOP AT ft_007 INTO ls_007 WHERE matnr = ls_x007-matnr
                                 AND lifnr = ls_x007-lifnr
                                 AND ebeln = ls_x007-ebeln.
      ADD 1 TO lv_zeile.
      ls_007-zeile  = lv_zeile.
      MODIFY ft_007 FROM ls_007 TRANSPORTING zeile.
      CLEAR ls_007.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION
*&---------------------------------------------------------------------*
FORM f_conversion  USING    fu_value fu_waers fu_tabname fu_fieldname
                   CHANGING fc_value.
  TYPES : BEGIN OF ty_date,
            dt01(2),
            dt02(2),
            dt03(4),
          END OF ty_date.

  DATA : dd03p_tab    TYPE STANDARD TABLE OF dd03p,
         ls_dd03p_tab LIKE LINE OF dd03p_tab,
         lv_value(50),
         lt_date      TYPE STANDARD TABLE OF ty_date,
         ls_date      LIKE LINE OF lt_date.

  lv_value    = fu_value.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = fu_tabname
    TABLES
      dd03p_tab     = dd03p_tab
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  READ TABLE dd03p_tab INTO ls_dd03p_tab
                       WITH KEY fieldname = fu_fieldname.

  CASE ls_dd03p_tab-datatype.
    WHEN 'QUAN' OR 'DEC'.
      TRANSLATE lv_value USING '. '.
      TRANSLATE lv_value USING ',.'.
      CONDENSE lv_value NO-GAPS.
      fc_value = lv_value.
    WHEN 'CURR'.
      TRANSLATE lv_value USING '. '.
      TRANSLATE lv_value USING ',.'.
      CONDENSE lv_value NO-GAPS.
      IF fu_waers = 'IDR'.
        fc_value = lv_value / 100.
      ELSE.
        fc_value = lv_value.
      ENDIF.
    WHEN 'UNIT'.
      CONDENSE lv_value NO-GAPS.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = lv_value
        IMPORTING
          output         = fc_value
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        fc_value = lv_value.
      ENDIF.
    WHEN 'DATS'.
      TRANSLATE lv_value USING '. '.
      TRANSLATE lv_value USING '/ '.
      CONDENSE lv_value NO-GAPS.
      CONCATENATE lv_value+4(4) lv_value+2(2) lv_value(2) INTO fc_value.
    WHEN 'CHAR'.
      CASE ls_dd03p_tab-convexit.
        WHEN 'ALPHA'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = fu_value
            IMPORTING
              output = fc_value.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   ft_lfa1 STRUCTURE lfa1
                                ft_total STRUCTURE zgdmmst0056.
  DATA : lt_x006   TYPE STANDARD TABLE OF zhsmmmdt006,
         ls_x006   LIKE LINE OF lt_x006,
         lt_x007   TYPE STANDARD TABLE OF zhsmmmdt007,
         ls_x007   LIKE LINE OF lt_x007,
         ls_007    TYPE zhsmmmdt007,
         ls_total  TYPE zgdmmst0056,
         lt_makt   TYPE STANDARD TABLE OF makt,
         ls_makt   LIKE LINE OF lt_makt,
         lv_bstmg  TYPE zhsmmmdt007-bstmg,
         lv_bstmg1 TYPE zhsmmmdt007-bstmg,
         ls_04z    LIKE LINE OF gt_004z.


  DATA : lv_total TYPE mseg-menge,
         lv_kbetr TYPE konp-kbetr,
         ls_lfa1  TYPE lfa1.

  IF gs_header-prgrp IS NOT INITIAL.
    SELECT SINGLE maktx
      FROM makt
      INTO gs_header-maktx
      WHERE matnr = gs_header-prgrp.

    gs_header-matnr = gs_header-prgrp.
  ENDIF.

  lt_x006[] = gt_006[].
  SORT lt_x006 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_x006 COMPARING matnr.
  IF lt_x006[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_x006
      WHERE matnr = lt_x006-matnr
        AND spras = sy-langu.
  ENDIF.

  LOOP AT gt_007 INTO ls_007.
    ADD ls_007-bstmg TO lv_total.
  ENDLOOP.

  lt_x007[] = gt_007[].
  SORT lt_x007 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING lifnr.
  IF lt_x007[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE ft_lfa1
      FOR ALL ENTRIES IN lt_x007
      WHERE lifnr = lt_x007-lifnr.

    LOOP AT lt_x007 INTO ls_x007.
      CLEAR lv_bstmg1.
      LOOP AT lt_x006 INTO ls_x006.
        CLEAR lv_bstmg.
        LOOP AT gt_007 INTO ls_007 WHERE lifnr = ls_x007-lifnr
                                     AND matnr = ls_x006-matnr.
          ls_total-lifnr  = ls_007-lifnr.
          ADD ls_007-bstmg TO lv_bstmg.
          ls_total-meins  = ls_007-bstme.
        ENDLOOP.

        IF lv_bstmg IS NOT INITIAL.
          ls_total-matnr = ls_x006-matnr.
          CLEAR ls_makt.
          READ TABLE lt_makt INTO ls_makt
                             WITH KEY matnr = ls_x006-matnr.
          IF sy-subrc = 0.
            ls_total-maktx = ls_makt-maktx.
          ENDIF.
          ls_total-menge  = lv_bstmg.
          WRITE lv_bstmg TO ls_total-menget UNIT ls_total-meins.
          CONDENSE ls_total-menget NO-GAPS.
          APPEND ls_total TO ft_total.
          ADD lv_bstmg TO lv_bstmg1.
          CLEAR : ls_total , lv_bstmg.
        ENDIF.
      ENDLOOP.

      READ TABLE ft_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = ls_x007-lifnr.
      IF sy-subrc = 0.
        TRY .
            lv_kbetr  = ( lv_bstmg1 / lv_total ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.
        WRITE lv_kbetr TO ls_lfa1-gbort DECIMALS 2.
        CONDENSE ls_lfa1-gbort NO-GAPS.
        MODIFY ft_lfa1 FROM ls_lfa1
                       TRANSPORTING gbort
                       WHERE lifnr = ls_x007-lifnr.
      ENDIF.
      CLEAR : lv_bstmg, lv_bstmg1.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREPARE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_SEND_PDF
*&---------------------------------------------------------------------*
FORM f_send_pdf  USING    fs_info      TYPE ssfcrescl
                          fs_options   TYPE ssfcresop
                          fu_vrsio.

  DATA : lt_otf      TYPE TABLE OF itcoo,
         lt_lines    TYPE TABLE OF tline,
         lv_xstring  TYPE xstring,
         lv_objlen   TYPE sood-objlen,
         lt_objbin   TYPE TABLE OF solix,
         lv_filepath TYPE string VALUE '/eprocurement',
         lv_filename TYPE string,
         ls_004z     LIKE LINE OF gt_004z,
         ls_data     LIKE LINE OF lt_objbin.

  CLEAR : lt_otf[], lt_lines[].

  lt_otf[] = fs_info-otfdata[].

  IF lt_otf[] IS NOT INITIAL.
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
        max_linewidth         = 132
      IMPORTING
        bin_filesize          = lv_objlen
        bin_file              = lv_xstring
      TABLES
        otf                   = lt_otf
        lines                 = lt_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_xstring
      TABLES
        binary_tab = lt_objbin[].

    READ TABLE gt_004z INTO ls_004z INDEX 1.

    CONCATENATE ls_004z-zalno fu_vrsio '.pdf' INTO lv_filename.
    CONCATENATE lv_filepath '/' lv_filename INTO lv_filename.
    OPEN DATASET lv_filename FOR OUTPUT IN BINARY MODE.
    IF sy-subrc = 0.
      LOOP AT lt_objbin INTO ls_data.
        TRANSFER ls_data TO lv_filename.
      ENDLOOP.
    ENDIF.
    CLOSE DATASET lv_filename.
*    PERFORM f_change_filemode USING lv_filename.
  ENDIF.
ENDFORM.                    " F_SEND_PDF

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_TEXT  text
*      -->P_LV_TDNAME  text
*----------------------------------------------------------------------*
FORM f_read_text  TABLES   ft_text  TYPE STANDARD TABLE
                  USING    fu_tdname.

  DATA : lines   TYPE STANDARD TABLE OF tline,
         ls_line LIKE LINE OF lines,
         lt_text TYPE STANDARD TABLE OF ty_text,
         ls_text LIKE LINE OF lt_text.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = fu_tdname
      object                  = 'TEXT'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  ls_text-head-tdobject  = 'TEXT'.
  ls_text-head-tdname    = fu_tdname.
  ls_text-head-tdid      = 'ST'.
  ls_text-head-tdspras   = sy-langu.
  ls_text-head-tdform    = 'SYSTEM'.
  LOOP AT lines INTO ls_line.
    ls_text-line           = ls_line-tdline.
    APPEND ls_text TO ft_text.
    CLEAR ls_text.
  ENDLOOP.

ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PDF
*&---------------------------------------------------------------------*
FORM f_display_pdf  USING    fs_info      TYPE ssfcrescl
                             fs_options   TYPE ssfcresop
                             fu_vrsio.

  CALL SCREEN 100.
ENDFORM.                    " F_DISPLAY_PDF

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  SET PF-STATUS 'PFSTATUS'.
ENDFORM.                    " F_STATUS
