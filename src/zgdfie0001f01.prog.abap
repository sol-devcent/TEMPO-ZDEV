*----------------------------------------------------------------------*
*   INCLUDE ZIBMFMMATDOCPRINTTEMPF01                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.

  CLEAR d_par.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_free_memory.

ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

  DATA ld_knumh LIKE a003-knumh.
  DATA ld_kbetr LIKE konp-kbetr.
  DATA lv_subrc TYPE sy-subrc.
  DATA ls_a003  TYPE a003.

**Get materai data
  SELECT * INTO TABLE t_fidt0002
           FROM zgdfidt0002.
  IF sy-subrc <> 0.
    MESSAGE i000(zab) WITH 'Materai data has not been maintained'.
    STOP.
  ENDIF.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = t_user.

**Get VAT-out value
  SELECT *
    FROM a003
    INTO CORRESPONDING FIELDS OF TABLE gt_a003
    WHERE kappl = 'TX'
      AND kschl = 'MWAS'
      AND aland = 'ID'.

  IF gt_a003[] IS NOT INITIAL.
    SELECT *
      FROM konp
      INTO CORRESPONDING FIELDS OF TABLE gt_konp
      FOR ALL ENTRIES IN gt_a003
      WHERE knumh = gt_a003-knumh.
  ENDIF.

  lv_subrc = 4.
  LOOP AT gt_a003 INTO ls_a003.
    IF ls_a003-mwskz = 'K2' OR
      ls_a003-mwskz = 'K5'.
      CLEAR lv_subrc.
    ENDIF.
  ENDLOOP.

  IF lv_subrc IS NOT INITIAL.
    MESSAGE i000(zab) WITH 'VAT-out rate has not been maintained'.
    STOP.
  ENDIF.

**  SELECT SINGLE knumh INTO ld_knumh
**                      FROM a003
**                      WHERE kappl = 'TX' AND
**                            kschl = 'MWAS' AND
**                            aland = 'ID' AND
**                            mwskz = d_taxcode.      "VAT out
**  IF sy-subrc = 0.
**    SELECT SINGLE kbetr INTO ld_kbetr
**                        FROM konp
**                        WHERE knumh = ld_knumh.
**    d_tax = ld_kbetr / 10.
**  ELSE.
**    MESSAGE i000(zab) WITH 'VAT-out rate has not been maintained'.
**    STOP.
**  ENDIF.

  PERFORM f_coretax_validate.

ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  CASE 'X'.
    WHEN p_crb OR p_rep OR p_prt OR p_rev OR p_fp OR p_rcr.
      PERFORM f_get_billing_data.
    WHEN p_pos.
      SELECT SINGLE *
        FROM bkpf
        INTO CORRESPONDING FIELDS OF gs_bkpf
        WHERE belnr = p_belnr
          AND gjahr = p_stjah.
    WHEN p_poc.
      PERFORM f_get_po.
  ENDCASE.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA : lv_fakno(21).

  CASE 'X'.
    WHEN p_crb.
      CALL SCREEN 9010.
      SET SCREEN 0.
*      LEAVE SCREEN.
    WHEN p_pos.
      PERFORM f_process_non_trade USING gs_bkpf-bukrs
                                        gs_bkpf-belnr
                                        gs_bkpf-budat+4(2)
                                        gs_bkpf-budat(4)
                                  CHANGING va_fakno.
      IF va_fakno IS NOT INITIAL.
        WRITE va_fakno TO lv_fakno USING EDIT MASK '__.__.__.___-________'.
        MESSAGE s000(zab) WITH 'No. FP' lv_fakno 'processed'.
      ENDIF.
*      IF va_fakno IS NOT INITIAL.
*        PERFORM f_print_form.
*      ENDIF.
    WHEN p_poc.
      CALL SCREEN 9020.
      SET SCREEN 0.
    WHEN p_rep.
      LOOP AT t_9010.
        CLEAR: t_kna1, t_t052, t_bkpf, t_fp.
        READ TABLE t_kna1 WITH KEY kunnr = t_9010-kunnr
                          BINARY SEARCH.
        READ TABLE t_t052 WITH KEY zterm = t_kna1-zterm
                          BINARY SEARCH.
        READ TABLE t_adrcz WITH KEY addrnumber = t_kna1-adrnr
                           BINARY SEARCH.
        MOVE-CORRESPONDING t_kna1 TO t_9010.
        t_9010-namec = t_kna1-name1.
        t_9010-ztag1 = t_t052-ztag1.
        t_9010-street = t_adrcz-street.
        READ TABLE t_bkpf WITH KEY belnr = t_9010-belnr
                                   gjahr = t_9010-stjah
                                   BINARY SEARCH.
        t_9010-bktxt = t_bkpf-bktxt.
        t_9010-xblnr = t_bkpf-xblnr.
        READ TABLE t_fp WITH KEY vbeln = t_9010-belnr
                                 gjahr = t_9010-stjah
                                 BINARY SEARCH.
        t_9010-fakturno = t_fp-fakturno.
        t_9010-fakdat = t_fp-fakdat.
        MODIFY t_9010
               TRANSPORTING namec stras ort01 pstlz stceg stkzu
                            zterm ztag1 bktxt xblnr
                            fakturno fakdat.
      ENDLOOP.
      PERFORM f_alv TABLES t_9010[].
    WHEN p_rcr.
      LOOP AT t_9010.
        CLEAR: t_kna1, t_t052, t_bkpf, t_fp.
        READ TABLE t_kna1 WITH KEY kunnr = t_9010-kunnr
                          BINARY SEARCH.
        READ TABLE t_t052 WITH KEY zterm = t_kna1-zterm
                          BINARY SEARCH.
        READ TABLE t_adrcz WITH KEY addrnumber = t_kna1-adrnr
                           BINARY SEARCH.
        MOVE-CORRESPONDING t_kna1 TO t_9010.
        t_9010-namec = t_kna1-name1.
        t_9010-ztag1 = t_t052-ztag1.
        t_9010-street = t_adrcz-street.
        READ TABLE t_bkpf WITH KEY belnr = t_9010-belnr
                                   gjahr = t_9010-stjah
                                   BINARY SEARCH.
        t_9010-bktxt = t_bkpf-bktxt.
        t_9010-xblnr = t_bkpf-xblnr.
        READ TABLE t_fp WITH KEY vbeln = t_9010-belnr
                                 gjahr = t_9010-stjah
                                 BINARY SEARCH.
        t_9010-fakturno = t_fp-fakturno.
        t_9010-fakdat = t_fp-fakdat.
*        SELECT SINGLE bezei INTO t_9010-bezei
*          FROM zftntreason WHERE kode = t_9010-kode.
        MODIFY t_9010
               TRANSPORTING namec stras ort01 pstlz stceg stkzu
                            zterm ztag1 bktxt xblnr
                            fakturno fakdat adrnr bezei.
      ENDLOOP.
      PERFORM f_alv TABLES t_9010[].


    WHEN p_prt OR p_fp.
      PERFORM f_process_selected_data.
      PERFORM f_print_form.
    WHEN p_rev.
      IF NOT t_lock[] IS INITIAL.
        PERFORM f_display_lock.
      ENDIF.
      IF NOT t_s911[] IS INITIAL.
        PERFORM f_reverse_doc.
      ENDIF.
  ENDCASE.

ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.

  DATA lw_crb_head LIKE t_crb_head.
  DATA lt_item LIKE t_crb_item OCCURS 0 WITH HEADER LINE.
  DATA ld_tax(2).
  DATA lw_zgdtxdt0005 LIKE zgdtxdt0005.

  WRITE d_tax TO ld_tax DECIMALS 0.

***Get signature
*  SELECT SINGLE nameadm jabatadm
*         INTO CORRESPONDING FIELDS OF lw_zgdtxdt0005
*         FROM zgdtxdt0005
*         WHERE bukrs = d_tnt_bukrs.

  PERFORM f_popup_signer CHANGING d_petugas
                                  d_jabat.

  CASE 'X'.
    WHEN p_crb.
      p_dest = p_dest1.
      IF p_cinvo IS INITIAL.
*        p_tdform = 'ZGDFIE0001_01'.
*        p_tdform = 'ZGDFIE0001_01N'
        p_tdform = 'ZTNTSDF0001_WOFP'.
      ELSE.
        p_tdform = 'ZGDFIE0001_01O'.
      ENDIF.
      IF sy-ucomm = 'POST'.
        CLEAR p_disp.
      ELSEIF sy-ucomm = 'OVIEW'.
        p_disp = 'X'.
      ENDIF.

    WHEN p_prt.
      IF p_rinvo EQ 'X'.
*          p_tdform = 'ZGDFIE0001_01O'.
*          p_tdform = 'ZGDFIE0001_01N'.
*          p_tdform = 'ZTNTSDF0001'. "If this is on, then can not change form
      ELSEIF p_faktu EQ 'X'.
        p_tdform = 'ZGDFIE0001_02O'.
      ENDIF.
  ENDCASE.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

***make it still possible to print during overview
***so always put '' for TDNOPRINT
*  d_output_opt-tdnoprint = p_disp.
  d_output_opt-tdnoprint = ''.

***print immediately
  d_output_opt-tdimmed = 'X'.
  d_output_opt-tddelete = 'X'.

  IF d_frm_subrc IS INITIAL AND
     NOT t_crb_head[] IS INITIAL.
    LOOP AT t_crb_head.
      MOVE-CORRESPONDING t_crb_head TO lw_crb_head.
      CALL FUNCTION 'Z_PPN11'
        EXPORTING
          pi_calty = 'F1'
          pi_datum = lw_crb_head-budat
        IMPORTING
          po_ppn   = lw_crb_head-ppncd.

      IF lw_crb_head-budat IN gr_coretax.
        lw_crb_head-ppncd = '00'.
      ENDIF.

      IF p_prt EQ 'X'.
*        IF t_crb_head-budat GE va_datab.
        va_fakno  = t_crb_head-fakno.
*        ENDIF.
      ENDIF.
      lw_crb_head-nameadm = d_petugas.
      lw_crb_head-jabatadm = d_jabat.
      IF NOT bkpf-xblnr IS INITIAL.
        lw_crb_head-xblnr    = bkpf-xblnr.
      ENDIF.
*      lw_crb_head-nameadm = lw_zgdtxdt0005-nameadm.
*      lw_crb_head-jabatadm = lw_zgdtxdt0005-jabatadm.

      lt_item[] = t_crb_item[].
      DELETE lt_item WHERE kunnr <> lw_crb_head-kunnr.
*-------One Spool
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
********to cater multiple printing
        d_ctrl_param-no_close = space.
      ENDAT.

      PERFORM f_new_ppn11 USING lw_crb_head-budat.

******call the generated function module of the form
      IF p_tdform = 'ZTNTSDF0001_WOFP'.
        PERFORM f_move_to_new_faktur_tnt TABLES lt_item
                                         USING lw_crb_head.

        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            gv_header          = gv_header
            taxrate            = ld_tax
            reprint            = 'X'
            tax                = 'G'
            multi              = ' '
          IMPORTING
            job_output_info    = d_job_output_info
          TABLES
            gt_detail          = gt_detail
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            my_exception       = 5
            OTHERS             = 6.
      ELSE.
        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            header             = lw_crb_head
            taxrate            = ld_tax
            reprint            = p_prt
            tax                = p_fp
            fakno              = va_fakno
          IMPORTING
            job_output_info    = d_job_output_info
          TABLES
            item               = lt_item
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            my_exception       = 5
            OTHERS             = 6.
      ENDIF.

      CASE sy-subrc.
        WHEN 0.
**********Printed indicator
          IF NOT d_job_output_info-spoolids IS INITIAL AND
             p_disp IS INITIAL.   "No need to count if print preview
            IF p_fp IS INITIAL.
              PERFORM f_save_print_counter.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDCASE.

*-----One Spool
      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.

  CLEAR: t_s911, t_ekko, t_lfa1, t_t001, t_adrc, t_9010, t_bkpf, bkpf,
         s911, kna1, ekko, lfa1, zgdfidt0001, zgdfidt0002, adrc, t001,
         t_status, t_crb_head, t_crb_item, t_9010x, d_par, t_konv,
         t_ekkof, t_item_zero, t_vrsio, t_fp, wa_fp, d_alv_desc, t_ekpo,
         t_fidt0003, t_bseg, t_lock, t_minus.
  REFRESH: t_s911, t_ekko, t_lfa1, t_t001, t_adrc, t_9010, t_bkpf,
           t_status, t_crb_head, t_crb_item, t_9010x, t_konv, t_ekkof,
           t_item_zero, t_vrsio, t_fp, t_ekpo, t_fidt0003, t_bseg,
           t_lock, t_minus.

*-Dequeue all lock entries
  CALL FUNCTION 'DEQUEUE_ALL'
* EXPORTING
*   _SYNCHRON       = ' '
    .

ENDFORM.                    " f_free_memory

**---------------------------------------------------------------------*
**       FORM f_print_data                                             *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
*FORM f_print_data.
*
*  t_main_tmp[] = t_main[].
*  ASSIGN t_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES <fs_table>.
*
*ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  IF p_crb = 'X'.
    d_alv_variant = '/STATUS'.
  ELSE.
    PERFORM f_alv_variant_exist USING   p_vari
                                        d_alv_variant.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       =
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME         =
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
      it_sort                  = t_alv_isort[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "f_alv


*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN p_crb.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '9' 'Status' '' '' '' '' '' '' '' '',
        'KUNNR' 'KNA1' 'KUNNR' '' '' 'Cust' '' '' '' '' '' '' '' '',
        'BELNR' 'S911' 'BELNR' '' '' '' '' '' '' '' '' '' '' '',
        'MSG' '' '' '' '100' 'Message' '' '' '' '' '' '' '' ''.
    WHEN p_rep.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'T001' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '',
        'EKGRP' 'S911' 'EKGRP' '' '' '' '' '' '' '' '' '' '' '',
        'BSART' 'S911' 'BSART' '' '' '' '' '' '' '' '' '' '' '',
        'BEDAT' 'S911' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '',
        'EBELN' 'S911' 'EBELN' '' '' '' '' '' '' '' '' '' '' '',
        'VRSIO' 'S911' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '',
        'HWAER' 'S911' 'HWAER' '' '' '' '' '' '' '' '' '' '' '',
        'NETWR' 'RGVALUE' 'WERTV10' '' '' 'PO Amt' '' '' '' '' ''
'HWAER' '' '',
        'KZWI1' 'S911' 'KZWI1' '' '' 'Fee' '' '' '' '' '' 'HWAER'
'' '',
        'BELNR' 'S911' 'BELNR' '' '' '' '' '' '' '' '' '' '' '',
        'STJAH' 'S911' 'STJAH' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR_01' 'S911' 'BELNR_01' '' '' 'Rev.doc' '' '' '' '' '' ''
'' '',
        'BUDAT' 'S911' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'S911' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'ZGDFIDT0001' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '',
        'PRCTR' 'ZGDFIDT0001' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '',
        'AUFNR' 'ZGDFIDT0001' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT_RV' 'ZGDFIDT0001' 'HKONT_RV' '' '' '' '' '' '' '' '' ''
'' '',
        'HKONT_MT' 'ZGDFIDT0001' 'HKONT_MT' '' '' '' '' '' '' '' '' ''
'' '',
        'TXT1' 'ZGDFIDT0001' 'TXT1' '' '' '' '' '' '' '' '' '' '' '',
        'TXT2' 'ZGDFIDT0001' 'TXT2' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZGDFIDT0001' 'GSBER' '' '' '' '' '' '' '' '' '' '' '',
        'BLART' 'ZGDFIDT0001' 'BLART' '' '' '' '' '' '' '' '' '' '' '',
        'ADRNR' 'T001' 'ADRNR' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'KNA1' 'KUNNR' '' '' 'Kode' '' '' '' '' '' '' '' '',
        'NAMEC' 'KNA1' 'NAME1' '' '' 'Customer' '' '' '' '' '' '' '' '',
        'STRAS' 'KNA1' 'STRAS' '' '' '' '' '' '' '' '' '' '' '',
        'ORT01' 'KNA1' 'ORT01' '' '' '' '' '' '' '' '' '' '' '',
        'PSTLZ' 'KNA1' 'PSTLZ' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'KNA1' 'STCEG' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'LFA1' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' 'Vendor' '' '' '' '' '' '' '' '',
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO' '' '' '' '' '' '' '' '' ''
'' '',
        'FAKDAT' 'ZGDTXDT0003' 'FAKDAT' '' '' '' '' '' '' '' '' '' ''
'',
        'ERFNAM' 'S911' 'ERFNAM' '' '' '' '' '' '' '' '' '' '' '',
        'AEDAT' 'S911' 'AEDAT' '' '' '' '' '' '' '' '' '' '' '',
        'BKTXT' 'BKPF' 'BKTXT' '' '' '' '' '' '' '' '' '' '' '',
        'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' ''.

    WHEN p_rcr.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'T001' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '',
        'EKGRP' 'S911' 'EKGRP' '' '' '' '' '' '' '' '' '' '' '',
        'BSART' 'S911' 'BSART' '' '' '' '' '' '' '' '' '' '' '',
        'BEDAT' 'S911' 'BEDAT' '' '' '' '' '' '' '' '' '' '' '',
        'EBELN' 'S911' 'EBELN' '' '' '' '' '' '' '' '' '' '' '',
        'VRSIO' 'S911' 'VRSIO' '' '' '' '' '' '' '' '' '' '' '',
        'HWAER' 'S911' 'HWAER' '' '' '' '' '' '' '' '' '' '' '',
        'NETWR' 'RGVALUE' 'WERTV10' '' '' 'PO Amt' '' '' '' '' ''
'HWAER' '' '',
        'KZWI1' 'S911' 'KZWI1' '' '' 'Fee' '' '' '' '' '' 'HWAER'
'' '',
        'BELNR' 'S911' 'BELNR' '' '' '' '' '' '' '' '' '' '' '',
        'STJAH' 'S911' 'STJAH' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR_01' 'S911' 'BELNR_01' '' '' 'Rev.doc' '' '' '' '' '' ''
'' '',
        'BUDAT' 'S911' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'S911' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '',
        'KOSTL' 'ZGDFIDT0001' 'KOSTL' '' '' '' '' '' '' '' '' '' '' '',
        'PRCTR' 'ZGDFIDT0001' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '',
        'AUFNR' 'ZGDFIDT0001' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT_RV' 'ZGDFIDT0001' 'HKONT_RV' '' '' '' '' '' '' '' '' ''
'' '',
        'HKONT_MT' 'ZGDFIDT0001' 'HKONT_MT' '' '' '' '' '' '' '' '' ''
'' '',
        'TXT1' 'ZGDFIDT0001' 'TXT1' '' '' '' '' '' '' '' '' '' '' '',
        'TXT2' 'ZGDFIDT0001' 'TXT2' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZGDFIDT0001' 'GSBER' '' '' '' '' '' '' '' '' '' '' '',
        'BLART' 'ZGDFIDT0001' 'BLART' '' '' '' '' '' '' '' '' '' '' '',
        'ADRNR' 'T001' 'ADRNR' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'KNA1' 'KUNNR' '' '' 'Kode' '' '' '' '' '' '' '' '',
        'NAMEC' 'KNA1' 'NAME1' '' '' 'Customer' '' '' '' '' '' '' '' '',
        'STRAS' 'KNA1' 'STRAS' '' '' '' '' '' '' '' '' '' '' '',
        'ORT01' 'KNA1' 'ORT01' '' '' '' '' '' '' '' '' '' '' '',
        'PSTLZ' 'KNA1' 'PSTLZ' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'KNA1' 'STCEG' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'LFA1' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' 'Vendor' '' '' '' '' '' '' '' '',
        'FAKTURNO' 'ZGDTXDT0003' 'FAKTURNO' '' '' '' '' '' '' '' '' ''
'' '',
        'FAKDAT' 'ZGDTXDT0003' 'FAKDAT' '' '' '' '' '' '' '' '' '' ''
'',
        'ERFNAM' 'S911' 'ERFNAM' '' '' '' '' '' '' '' '' '' '' '',
        'AEDAT' 'S911' 'AEDAT' '' '' '' '' '' '' '' '' '' '' '',
        'BKTXT' 'BKPF' 'BKTXT' '' '' '' '' '' '' '' '' '' '' '',
        'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '',
*        'KODE'  'ZS911KOR' 'KODE' '' '' '' '' '' '' '' '' '' '' '',
*        'BEZEI' 'ZFTNTREASON' 'BEZEI' '' '' '' '' '' '' '' '' '' '' '',
        'ZUSER' 'ZS911KOR' 'ZUSER' '' '' '' '' '' '' '' '' '' '' '',
        'ZDATE' 'ZS911KOR' 'ZDATE' '' '' '' '' '' '' '' '' '' '' '',
        'ZTEXT1' 'ZS911KOR' 'ZTEXT1' '' '120' 'Reason Text 1' '' '' '' '' '' '' '' '',
        'ZTEXT2' 'ZS911KOR' 'ZTEXT2' '' '120' 'Reason Text 2' '' '' '' '' '' '' '' '',
        'ZTEXT3' 'ZS911KOR' 'ZTEXT3' '' '120' 'Reason Text 3' '' '' '' '' '' '' '' ''.
  ENDCASE.

ENDFORM.                    " F_FIELDCAT


*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.





ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    "f_build_event_exit


*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.

ENDFORM.                    "f_build_layout


*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print


*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
*  ld_sort-fieldname = 'BUKRS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.
  IF NOT p_rep IS INITIAL.
    ld_sort-fieldname = 'BELNR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'BUDAT'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    ld_sort-fieldname = 'KUNNR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'NAMEC'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.
  ENDIF.
  CLEAR ld_sort.
ENDFORM.                    "f_build_sortfield



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING d_alv_desc.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.


  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.


  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " f_clear_alv_data



*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
  CASE 'X'.
    WHEN p_rcr.
      SET TITLEBAR 'TITLE9013'.
  ENDCASE.

ENDFORM.                    " F_SET_PF_STATUS


*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message


*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.


ENDFORM.                    " F_ALV_VARIANT_EXIST

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA ld_belnr LIKE bsid-belnr.
  DATA ld_ebeln LIKE ekko-ebeln.
  DATA ld_bukrs LIKE bsid-bukrs.
  DATA ld_gjahr LIKE bsid-gjahr.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      CASE fu_selfield-fieldname.
        WHEN 'BELNR'.
          ld_belnr = fu_selfield-value.
          ld_bukrs = t_9010-bukrs.
          ld_gjahr = t_9010-stjah.
          SET PARAMETER ID 'BLN' FIELD ld_belnr.
          SET PARAMETER ID 'BUK' FIELD ld_bukrs.
          SET PARAMETER ID 'GJR' FIELD ld_gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        WHEN 'EBELN'.
          ld_ebeln = fu_selfield-value.
          SET PARAMETER ID 'BES' FIELD ld_ebeln.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

ENDFORM.                    "f_user_command
*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant
                                   fc_desc.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
    fc_desc = ld_variant-text.
  ENDIF.

ENDFORM.                    " F_F4_FOR_VARIANT_ALV


*---------------------------------------------------------------------*
*       FORM f_after_line_output                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  LINEINFO                                                      *
*---------------------------------------------------------------------*
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
*  DATA: gs_lineinfo TYPE kkblo_lineinfo.
  BREAK-POINT.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  f_modify_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen.

  LOOP AT SCREEN.
    IF screen-group1 = 'POS'.
      screen-active  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  CASE 'X'.
    WHEN p_crb.
      d_screen = '9000'.
    WHEN p_pos.
      LOOP AT SCREEN.
        IF screen-group1 = 'INV'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'R00'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN p_poc.
      d_screen = '9001'.
    WHEN p_rep.
      d_screen = '9002'.
    WHEN p_prt.
      d_screen = '9003'.
    WHEN p_rev.
      d_screen = '9004'.
    WHEN p_fp.
      d_screen = '9005'.
      LOOP AT SCREEN.
        IF screen-group1 = 'INV'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN p_pse.
    WHEN p_rcr.
      d_screen = '9007'.

  ENDCASE.

  CASE d_screen.
    WHEN '9000'.
      SET TITLEBAR 'TITLE9010'.
      LOOP AT SCREEN.
        IF screen-name = 'S_BELNR-LOW' OR
           screen-name = 'S_BELNR-HIGH' OR
           screen-name = '%_S_BELNR_%_APP_%-TEXT' OR
           screen-name = '%_S_BELNR_%_APP_%-OPTI_PUSH' OR
           screen-name = '%_S_BELNR_%_APP_%-TO_TEXT' OR
           screen-name = '%_S_BELNR_%_APP_%-VALU_PUSH' OR
           screen-name = '%_P_VARI_%_APP_%-TEXT' OR
           screen-name = 'P_VARI' OR
           screen-name = 'S_BUDAT-LOW' OR
           screen-name = 'S_BUDAT-HIGH' OR
           screen-name = '%_S_BUDAT_%_APP_%-TEXT' OR
           screen-name = '%_S_BUDAT_%_APP_%-OPTI_PUSH' OR
           screen-name = '%_S_BUDAT_%_APP_%-TO_TEXT' OR
           screen-name = '%_S_BUDAT_%_APP_%-VALU_PUSH' OR
*           screen-name = '%_S_BUKRS_%_APP_%-TEXT' OR
           screen-name = '%_S_BUKRS_%_APP_%-OPTI_PUSH' OR
*           screen-name = 'S_BUKRS-LOW' OR
           screen-name = '%_S_BUKRS_%_APP_%-TO_TEXT' OR
           screen-name = 'S_BUKRS-HIGH' OR
           screen-name = '%_S_BUKRS_%_APP_%-VALU_PUSH'. " OR
*           screen-name = '%_S_WERKS_%_APP_%-TEXT' OR
*****           screen-name = '%_S_WERKS_%_APP_%-OPTI_PUSH' OR
*           screen-name = 'S_WERKS-LOW' OR
*****           screen-name = '%_S_WERKS_%_APP_%-TO_TEXT' OR
*****           screen-name = 'S_WERKS-HIGH' OR
*****           screen-name = '%_S_WERKS_%_APP_%-VALU_PUSH'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN '9001'.
      SET TITLEBAR 'TITLE9020'.
    WHEN '9002'.
      SET TITLEBAR 'TITLE9011'.
      LOOP AT SCREEN.
        IF screen-name = '%_P_DEST1_%_APP_%-TEXT' OR
           screen-name = 'P_DEST1' OR
           screen-name = '%_P_BUKRS_%_APP_%-TEXT' OR
           screen-name = 'P_BUKRS' OR
           screen-name = '%_P_WERKS_%_APP_%-TEXT' OR
           screen-name = 'P_WERKS'.
*           screen-name = '%_S_KODE_%_APP_%-TEXT' OR
*           screen-name = '%_S_KODE_%_APP_%-OPTI_PUSH' OR
*           screen-name = 'S_KODE-LOW' OR
*           screen-name = '%_S_KODE_%_APP_%-TO_TEXT' OR
*           screen-name = 'S_KODE-HIGH' OR
*           screen-name = '%_S_KODE_%_APP_%-VALU_PUSH'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN '9003'.
      SET TITLEBAR 'TITLE9012'.
*      LOOP AT SCREEN.
*        IF screen-name = 'P_ZKODE' OR
*           screen-name =  '%_P_ZKODE_%_APP_%-TEXT'.
*          screen-active = 0.
*          screen-invisible = 1.
*        ENDIF.
*        MODIFY SCREEN.
*      ENDLOOP.
    WHEN '9008'.
      SET TITLEBAR 'TITLE9014'.
    WHEN '9004'.
      SET TITLEBAR 'TITLE9050'.
      LOOP AT SCREEN.
        IF screen-name = '%_P_TDFORM_%_APP_%-TEXT' OR
           screen-name = 'P_TDFORM' OR
           screen-name = '%_P_DEST_%_APP_%-TEXT' OR
           screen-name = 'P_DEST' OR
           screen-name = 'P_DISP' OR
           screen-name = '%_P_DISP_%_APP_%-TEXT'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN '9005'.
      SET TITLEBAR 'TITLE9060'.
*      LOOP AT SCREEN.
*        IF screen-name = 'P_ZKODE' OR
*           screen-name =  '%_P_ZKODE_%_APP_%-TEXT'.
*          screen-active = 0.
*          screen-invisible = 1.
*        ENDIF.
*        MODIFY SCREEN.
*      ENDLOOP.
    WHEN '9006'.
      SET TITLEBAR 'TITLE9011'.
      LOOP AT SCREEN.
        IF screen-name = '%_P_DEST1_%_APP_%-TEXT' OR
           screen-name = 'P_DEST1' OR
           screen-name = '%_P_BUKRS_%_APP_%-TEXT' OR
           screen-name = 'P_BUKRS' OR
           screen-name = '%_P_WERKS_%_APP_%-TEXT' OR
           screen-name = 'P_WERKS'. " OR
*           screen-name = '%_S_KODE_%_APP_%-TEXT'. " OR
*           screen-name = '%_S_KODE_%_APP_%-OPTI_PUSH'. " OR
*           screen-name = 'S_KODE-LOW' OR
*           screen-name = '%_S_KODE_%_APP_%-TO_TEXT' OR
*           screen-name = 'S_KODE-HIGH' OR
*           screen-name = '%_S_KODE_%_APP_%-VALU_PUSH'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN '9007'.
      SET TITLEBAR 'TITLE9013'.
      LOOP AT SCREEN.
        IF screen-name = '%_P_DEST1_%_APP_%-TEXT' OR
           screen-name = 'P_DEST1' OR
           screen-name = '%_P_BUKRS_%_APP_%-TEXT' OR
           screen-name = 'P_BUKRS' OR
           screen-name = '%_P_WERKS_%_APP_%-TEXT' OR
           screen-name = 'P_WERKS'." OR
*           screen-name = '%_S_KODE_%_APP_%-TEXT' OR
*           screen-name = '%_S_KODE_%_APP_%-OPTI_PUSH' OR
*           screen-name = 'S_KODE-LOW' OR
*           screen-name = '%_S_KODE_%_APP_%-TO_TEXT' OR
*           screen-name = 'S_KODE-HIGH' OR
*           screen-name = '%_S_KODE_%_APP_%-VALU_PUSH'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
  CLEAR d_screen.

ENDFORM.                    " f_modify_screen

*&---------------------------------------------------------------------*
*&      Form  f_get_billing_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_billing_data.
  DATA: l_ebelp LIKE ekpo-ebelp,
        sw      TYPE i.

  DATA lt_cust LIKE t_adrc OCCURS 1 WITH HEADER LINE.
  DATA ld_no LIKE t_9010-no.
  DATA lt_kunnr LIKE t_9010 OCCURS 0 WITH HEADER LINE.
  DATA lt_kna1x LIKE t_kna1 OCCURS 0 WITH HEADER LINE.
  DATA lt_for LIKE t_s911 OCCURS 0 WITH HEADER LINE.
  DATA lt_ekko LIKE t_ekko OCCURS 0 WITH HEADER LINE.
  DATA ld_ekpo.
  DATA ld_cust_flag.
  DATA ld_uname LIKE sy-uname.

**Get all selected Fee charges records
  CASE 'X'.
****Selection for Create Billing
    WHEN p_crb.
      SELECT * INTO TABLE t_s911
               FROM s911
               WHERE bukrs IN s_bukrs AND
                     ekgrp IN s_ekgrp AND
                     bsart IN s_bsart AND
                     bedat IN s_bedat AND
                     ebeln IN s_ebeln AND
                     netwr IN s_netwr AND
                     belnr = ''. "AND
*                     kzwi1 <> 0.

      IF NOT t_s911[] IS INITIAL.
        SELECT ebeln
               INTO TABLE t_ekpo
               FROM ekpo
               FOR ALL ENTRIES IN t_s911
               WHERE ebeln = t_s911-ebeln AND
                     werks IN s_werks.
*                     werks = s_werks-low.
        SORT t_ekpo BY ebeln.

        SELECT spmon bukrs ekgrp bsart bedat ebeln vrsio zdesc1
          FROM zgdfidt0005
          INTO TABLE gt_zgdfidt0005
          FOR ALL ENTRIES IN t_s911
          WHERE spmon   EQ t_s911-spmon AND
                bukrs   EQ t_s911-bukrs AND
                ekgrp   EQ t_s911-ekgrp AND
                bsart   EQ t_s911-bsart AND
                bedat   EQ t_s911-bedat AND
                ebeln   EQ t_s911-ebeln AND
                vrsio   EQ t_s911-vrsio.
      ENDIF.

****Selection for Report
    WHEN p_rep.
      SELECT * INTO TABLE t_s911
               FROM s911
               WHERE bukrs IN s_bukrs AND
                     ekgrp IN s_ekgrp AND
                     bsart IN s_bsart AND
                     bedat IN s_bedat AND
                     ebeln IN s_ebeln AND
                     netwr IN s_netwr AND
                     belnr IN s_belnr AND
                     budat IN s_budat.

*-----Get additional data from BKPF
      IF sy-subrc = 0.
*-----Get additional data from ZGDFIDT0005
        SELECT spmon bukrs ekgrp bsart bedat ebeln vrsio zdesc1
          FROM zgdfidt0005
          INTO TABLE gt_zgdfidt0005
          FOR ALL ENTRIES IN t_s911
          WHERE spmon   EQ t_s911-spmon AND
                bukrs   EQ t_s911-bukrs AND
                ekgrp   EQ t_s911-ekgrp AND
                bsart   EQ t_s911-bsart AND
                bedat   EQ t_s911-bedat AND
                ebeln   EQ t_s911-ebeln AND
                vrsio   EQ t_s911-vrsio.

*-------Get PO for selected Plant
        SELECT ebeln
               INTO TABLE t_ekpo
               FROM ekpo
               FOR ALL ENTRIES IN t_s911
               WHERE ebeln = t_s911-ebeln AND
                     werks IN s_werks.
        SORT t_ekpo BY ebeln.

*-------Get Customer number since there are company codes linked to
*-------more than one customers
        PERFORM f_get_customer_from_bseg TABLES t_s911
                                         USING  d_tnt_bukrs.
      ENDIF.

****Selection for Reprint
    WHEN p_rcr.
      SELECT * INTO TABLE t_s911kor
               FROM zs911kor
               WHERE bukrs IN s_bukrs AND
                     ekgrp IN s_ekgrp AND
                     bsart IN s_bsart AND
                     bedat IN s_bedat AND
                     ebeln IN s_ebeln AND
                     netwr IN s_netwr AND
                     belnr IN s_belnr AND
                     budat IN s_budat." AND
*                     kode  IN s_kode.

*-----Get additional data from BKPF
      IF sy-subrc = 0.
*-------Get PO for selected Plant
        SELECT ebeln
               INTO TABLE t_ekpo
               FROM ekpo
               FOR ALL ENTRIES IN t_s911kor
               WHERE ebeln = t_s911kor-ebeln AND
                     werks IN s_werks.
        SORT t_ekpo BY ebeln.

*-------Get Customer number since there are company codes linked to
*-------more than one customers
        PERFORM f_get_customer_from_bseg TABLES t_s911kor
                                         USING  d_tnt_bukrs.
      ENDIF.

    WHEN p_prt OR p_rev OR p_fp.
      SELECT * INTO TABLE t_s911
                    FROM s911
                    WHERE
*                          bukrs = p_bukrs AND
                          belnr = p_belnr AND
                          stjah = p_stjah.

*-----Get Customer number since there are company codes linked to
*-----more than one customers
      PERFORM f_get_customer_from_bseg TABLES t_s911
                                       USING  d_tnt_bukrs.

  ENDCASE.

  CASE 'X'.
    WHEN p_rcr.
      IF t_s911kor[] IS INITIAL.
        MESSAGE i000(zab) WITH 'No data selected'.
        STOP.
      ELSE.
        PERFORM f_proses_report_kor.
      ENDIF.

    WHEN OTHERS.
      IF t_s911[] IS INITIAL.
        MESSAGE i000(zab) WITH 'No data selected'.
        STOP.
      ELSE.
        REFRESH: s_ebeln.
        LOOP AT t_s911.
          s_ebeln-low = t_s911-ebeln.
          s_ebeln-option = 'EQ'.
          s_ebeln-sign   = 'I'.
          APPEND s_ebeln.
        ENDLOOP.
        IF NOT p_rev IS INITIAL.  "Reverse only
*-----Lock only for Reverse
          LOOP AT t_s911.
            PERFORM f_lock_s911_rec USING t_s911
                                    CHANGING ld_uname.
            IF NOT ld_uname IS INITIAL.
              t_lock-ebeln = t_s911-ebeln.
              t_lock-uname = ld_uname.
              APPEND t_lock.
              DELETE t_s911.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

      IF p_rev IS INITIAL. "no need to process for REVERSE
**--Get Customer data from Company code table
        SELECT bukrs butxt adrnr
               INTO TABLE t_t001
               FROM t001
               WHERE bukrs IN s_bukrs.
        IF sy-subrc = 0.
          SORT t_t001 BY bukrs.
          SELECT addrnumber sort2
                 INTO TABLE t_adrc
                 FROM adrc
                 FOR ALL ENTRIES IN t_t001
                 WHERE addrnumber = t_t001-adrnr.
          SORT t_adrc BY addrnumber.
          IF sy-subrc <> 0.
            MESSAGE i000(zab) WITH 'Please maintain customer number'
                                   'for selected company codes'.
            STOP.
          ENDIF.
        ENDIF.

**--Check customer data
        IF p_crb = 'X'.
          READ TABLE t_fidt0003 WITH KEY bukrs = s_bukrs-low
                                         werks = s_werks-low
                                         BINARY SEARCH.
          IF sy-subrc = 0.
            ld_cust_flag = 'X'.  "customer is more than one
          ELSE.
            CLEAR ld_cust_flag.
            lt_cust[] = t_adrc[].
            SORT lt_cust BY sort2.
            READ TABLE lt_cust WITH KEY sort2 = '' BINARY SEARCH.
            IF sy-subrc = 0.
              READ TABLE t_t001 WITH KEY adrnr = lt_cust-addrnumber.
              MESSAGE i000(zab) WITH 'Please maintain customer number'
                                     'for company'
                                     t_t001-bukrs.
              STOP.
            ENDIF.
          ENDIF.
        ENDIF.

**--Get Config data
        SELECT * INTO TABLE t_fidt0001
                 FROM zgdfidt0001
                 WHERE ekgrp IN s_ekgrp AND
                       bsart IN s_bsart.
        SORT t_fidt0001 BY ekgrp bsart.

**--Get PO data
*    SELECT ebeln lifnr knumv waers
*           INTO CORRESPONDING FIELDS OF TABLE t_ekko
*           FROM ekko
*           WHERE ebeln IN s_ebeln.

        SELECT ebeln lifnr knumv waers
               INTO CORRESPONDING FIELDS OF TABLE t_ekko
               FROM ekko
               FOR ALL ENTRIES IN t_s911
               WHERE ebeln EQ t_s911-ebeln.

        IF sy-subrc = 0.
          SORT t_ekko BY ebeln.
          SELECT lifnr name1
                 INTO CORRESPONDING FIELDS OF TABLE t_lfa1
                 FROM lfa1
                 FOR ALL ENTRIES IN t_ekko
                 WHERE lifnr = t_ekko-lifnr.
          SORT t_lfa1 BY lifnr.

          SELECT ebeln ebelp loekz  netwr
                 INTO CORRESPONDING FIELDS OF TABLE t_ekpo1
                 FROM ekpo
                 FOR ALL ENTRIES IN t_ekko
                 WHERE ebeln = t_ekko-ebeln.

*      delete t_ekpo1 where loekz = 'L'.
*      delete ADJACENT DUPLICATES FROM t_ekpo1 COMPARING ebeln.
          sw = 0.
          CLEAR: l_ebelp.
          IF t_ekpo1[] IS NOT INITIAL.
            SORT t_ekpo1 BY ebeln ebelp loekz.
            SORT t_ekko BY ebeln.
            SORT t_ekpo1 BY ebeln ebelp loekz.
            LOOP AT t_ekko.
              sw = 2.
              LOOP AT t_ekpo1 WHERE ebeln = t_ekko-ebeln.
                IF t_ekpo1-loekz NE 'L'.
                  IF t_ekpo1-netwr NE 0.
                    t_ekko-ebelp = t_ekpo1-ebelp.
                    sw = 0.
                    EXIT.
                  ENDIF.
                ELSE.
                  IF t_ekpo1-netwr NE 0.
                    l_ebelp = t_ekpo1-ebelp.
                    sw = 1.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              IF sw = 1.
                t_ekko-ebelp =  l_ebelp.
              ENDIF.
*          READ TABLE t_ekpo1 WITH KEY ebeln = t_ekko-ebeln BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            t_ekko-ebelp = t_ekpo1-ebelp.
*          ENDIF.
              MODIFY t_ekko.
            ENDLOOP.
          ENDIF.

**----Get more data from PO table for foreign currency
          IF NOT t_s911[] IS INITIAL.
            t_ekkof[] = t_ekko[].
            DELETE t_ekkof WHERE waers = 'IDR'.
*_______Added By SAP_DEV06 Yudhois 9-04-2007.
            IF  NOT t_ekkof[] IS INITIAL.
*_______End of Added By SAP_DEV06 Yudhois 9-04-2007.
              SORT t_ekkof BY knumv ebelp.
              SELECT knumv kposn kbetr kwert
                     INTO CORRESPONDING FIELDS OF TABLE t_konv
                     FROM konv
                     FOR ALL ENTRIES IN t_ekkof
                     WHERE knumv = t_ekkof-knumv AND
                           kposn = t_ekkof-ebelp AND
                           kappl = 'M' AND
                           kschl = 'ZFEE'.
*_______Added By SAP_DEV06 Yudhois 9-04-2007.
            ENDIF.
*_______End of Added By SAP_DEV06 Yudhois 9-04-2007.
            SORT t_konv BY knumv.
****************** Tanbah disini untuk delete item yg sudah didelete
            IF t_ekpo1[] IS NOT INITIAL.
              LOOP AT t_ekpo1.
                DELETE t_konv WHERE knumv = t_ekpo1-knumv AND kposn = t_ekpo1-ebelp.
              ENDLOOP.
            ENDIF.
******************************************************

          ENDIF.
        ENDIF.

***-For printing FP - Rahmadi 03/04/2005
        IF NOT p_fp IS INITIAL OR
          p_faktu IS NOT INITIAL.
          SELECT SINGLE a~fakdat
                        b~fakturno b~vbeln b~gjahr b~ppnlast b~form
                                       INTO CORRESPONDING FIELDS OF wa_fp
                                       FROM zgdtxdt0003 AS a JOIN
                                            zgdtxdt0002 AS b
                                       ON a~bukrs = b~bukrs AND
                                          a~brnch = b~brnch AND
                                          a~busln = b~busln AND
                                          a~fakturno = b~fakturno AND
                                          a~vbeln    = b~vbeln
                                       WHERE a~bukrs = d_tnt_bukrs AND
                                             a~batal = '' AND
                                             b~vbeln = p_belnr AND
                                             b~gjahr = p_stjah.
          IF sy-subrc <> 0.
            MESSAGE i000(zab) WITH 'Faktur pajak has not been processed'.
            PERFORM f_free_memory.
            STOP.
          ELSE.
            IF wa_fp-fakturno CP 'BATAL' OR
               wa_fp-ppnlast = 0.
              MESSAGE i000(zab) WITH 'Faktur pajak has been cancelled'.
              PERFORM f_free_memory.
              STOP.
            ENDIF.
          ENDIF.
        ENDIF.

**--Copy original data
        t_s911_orig[] = t_s911[].

**--Forming screen table
        SORT t_s911 BY bukrs ekgrp bsart ebeln.
        CLEAR ld_no.
        LOOP AT t_s911.

*-----Get only PO for selected Plants for Billing Create & Report
          ld_ekpo = 'X'.
          IF NOT p_rep IS INITIAL OR
             NOT p_crb IS INITIAL.
            IF t_s911-ebeln CS 'X'.
              ld_ekpo = 'X'.
*          IF NOT p_crb IS INITIAL AND
*             NOT s_werks-low IS INITIAL.
*            CLEAR ld_ekpo.
*          ENDIF.
            ELSE.
              READ TABLE t_ekpo WITH KEY ebeln = t_s911-ebeln BINARY SEARCH.
              IF sy-subrc = 0.
                ld_ekpo = 'X'.
              ELSE.
                CLEAR ld_ekpo.
              ENDIF.
            ENDIF.
          ENDIF.

          IF ld_ekpo = 'X'.
*-------Lock object
            IF p_rep IS INITIAL AND
              p_prt IS INITIAL AND
              p_fp IS INITIAL AND
              p_rcr IS INITIAL.  "No need to lock for report
              PERFORM f_lock_s911_rec USING t_s911
                                      CHANGING ld_uname.
              IF NOT ld_uname IS INITIAL.
                t_lock-ebeln = t_s911-ebeln.
                t_lock-uname = ld_uname.
                APPEND t_lock.
                DELETE t_s911.
              ENDIF.
            ENDIF.

            CLEAR: t_9010, t_t001, t_adrc, t_ekko, t_lfa1, t_fidt0001,
                   t_konv.
            IF ld_uname IS INITIAL.   "not locked
              ld_no = ld_no + 1.
              MOVE-CORRESPONDING t_s911 TO t_9010.

***--Customer
              READ TABLE t_t001 WITH KEY bukrs = t_s911-bukrs BINARY SEARCH.
              IF p_crb = 'X'.
                IF ld_cust_flag IS INITIAL.
                  READ TABLE t_adrc WITH KEY addrnumber = t_t001-adrnr
                                    BINARY SEARCH.
                  t_9010-kunnr = t_adrc-sort2.
                ELSE.
                  t_9010-kunnr = d_kunnr.
                ENDIF.
                t_9010-namec = t_t001-butxt.
              ELSE.
                READ TABLE t_bseg WITH KEY belnr = t_s911-belnr
                                           gjahr = t_s911-stjah
                                           BINARY SEARCH.
                IF sy-subrc = 0.
                  t_9010-kunnr = t_bseg-kunnr.
                  t_9010-kidno = t_bseg-kidno.
                ELSE.
                  READ TABLE t_adrc WITH KEY addrnumber = t_t001-adrnr
                                    BINARY SEARCH.
                  t_9010-kunnr = t_adrc-sort2.
                  t_9010-namec = t_t001-butxt.
                ENDIF.
              ENDIF.

****--Vendor
              IF ld_ekpo = 'X' AND              "only if exist in EKKO~EKPO
                 NOT t_s911-ebeln CS 'X'.
                READ TABLE t_ekko WITH KEY ebeln = t_s911-ebeln
                           BINARY SEARCH.
                READ TABLE t_lfa1 WITH KEY lifnr = t_ekko-lifnr
                           BINARY SEARCH.
                t_9010-lifnr = t_lfa1-lifnr.
                t_9010-name1 = t_lfa1-name1.

****--Value if PO is in foreign currency
                CLEAR t_konv-kbetr.
                IF t_ekko-waers <> 'IDR'.
                  READ TABLE t_konv WITH KEY knumv = t_ekko-knumv
                                    BINARY SEARCH.
***** Koreksi pengambilan Fee Koreksi 28/09/2005
                  IF t_9010-vrsio EQ '000' AND
                    t_9010-netwr NE 0.
***** End Koreksi
                    IF t_9010-kzwi1 < 0.
                      t_9010-kzwi1 = ( -1 ) * t_konv-kbetr.
                    ELSE.
                      t_9010-kzwi1 = t_konv-kbetr.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.

****--Get data based on EKGRP & BSART
              READ TABLE t_fidt0001 WITH KEY ekgrp = t_s911-ekgrp
                                             bsart = t_s911-bsart
                                             BINARY SEARCH.

*-----Keep Customer company code for Saving purpose
              t_9010-bukrs_d = t_s911-bukrs.

              MOVE-CORRESPONDING t_fidt0001 TO t_9010.
              CONCATENATE t_s911-ekgrp t_s911-bsart INTO t_9010-ekgart.

****--Status
              IF t_s911-vrsio = d_vrsio_orig.
                t_9010-sts = d_new.
              ELSE.
                t_9010-sts = d_cor.
              ENDIF.

****--line number
              t_9010-no = ld_no.

**** Add by budi 30/11/2005
              READ TABLE t_bkpf WITH KEY belnr = t_9010-belnr.
              IF sy-subrc = 0.
                t_9010-xblnr = t_bkpf-xblnr.
              ENDIF.
**** EndAdd

***** Ambil Description dari table ZGDFIE0005
              IF p_crb IS NOT INITIAL OR
                p_rep IS NOT INITIAL.
                IF t_9010-name1 IS INITIAL.
                  READ TABLE gt_zgdfidt0005 WITH KEY spmon  = t_s911-spmon
                                                     bukrs  = t_s911-bukrs
                                                     ekgrp  = t_s911-ekgrp
                                                     bsart  = t_s911-bsart
                                                     bedat  = t_s911-bedat
                                                     ebeln  = t_s911-ebeln
                                                     vrsio  = t_s911-vrsio.
                  IF sy-subrc EQ 0.
                    t_9010-name1  = gt_zgdfidt0005-zdesc1.
                  ENDIF.
                ENDIF.
              ENDIF.

***** Jika amount = 0 dan fee ada isinya maka data tidak tampil dan modify table S911nya
*              IF t_9010-netwr EQ 0.
*-------Update database table
*                t_s911-kzwi1 = 0.
*                ld_no = ld_no - 1.
*                MODIFY TABLE t_s911 TRANSPORTING kzwi1.
*                UPDATE s911 FROM t_s911.
*                COMMIT WORK.
*              ELSE.
              APPEND t_9010.
*              ENDIF.
            ELSE.
              CONTINUE.
            ENDIF.
          ELSE.
            CONTINUE.
          ENDIF.

        ENDLOOP.

*  SORT t_9010 BY kunnr ekgrp bsart.

****Get Further Customer data
        lt_kunnr[] = t_9010[].
        SORT lt_kunnr BY kunnr.
        DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.
        IF NOT lt_kunnr[] IS INITIAL.
          SELECT a~kunnr a~name1 a~stras a~ort01 a~pstlz a~stceg a~stkzu
                 a~adrnr a~stcd1
                 b~bukrs b~zterm
                 INTO CORRESPONDING FIELDS OF TABLE t_kna1
                 FROM kna1 AS a JOIN knb1 AS b
                 ON a~kunnr = b~kunnr
                 FOR ALL ENTRIES IN lt_kunnr
                 WHERE a~kunnr = lt_kunnr-kunnr AND
                       b~bukrs = d_tnt_bukrs.
          IF sy-subrc = 0.
            SELECT addrnumber street name_co str_suppl1 str_suppl2
                   str_suppl3 location post_code1
                   INTO TABLE t_adrcz
                   FROM adrc
                   FOR ALL ENTRIES IN t_kna1
                   WHERE addrnumber = t_kna1-adrnr.
            SORT t_adrcz BY addrnumber.

            SORT t_kna1 BY kunnr.
            lt_kna1x[] = t_kna1[].
            SORT lt_kna1x BY zterm.
            DELETE ADJACENT DUPLICATES FROM lt_kna1x COMPARING zterm.
            SELECT zterm ztag1
                   INTO TABLE t_t052
                   FROM t052
                   FOR ALL ENTRIES IN lt_kna1x
                   WHERE zterm = lt_kna1x-zterm.
            SORT t_t052 BY zterm.
          ENDIF.
        ENDIF.

      ENDIF.
  ENDCASE.
ENDFORM.                    " f_get_billing_data

*&---------------------------------------------------------------------*
*&      Form  f_select_deselect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0011   text
*----------------------------------------------------------------------*
FORM f_select_deselect USING    fu_value.

  t_9010-select = fu_value.
  MODIFY t_9010 TRANSPORTING select
                WHERE select <> fu_value.

ENDFORM.                    " f_select_deselect

*---------------------------------------------------------------------*
*       FORM f_process_selected_data                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_process_selected_data.

  DATA lw_9010x LIKE t_9010.
  DATA ld_kzwi1 LIKE s911-kzwi1.
  DATA ld_tot LIKE s911-kzwi1.
  DATA ld_grosstot LIKE s911-kzwi1.
  DATA ld_grossnum(11) TYPE n.
  DATA lt_9010y LIKE t_9010 OCCURS 1 WITH HEADER LINE.
  DATA ld_amount LIKE s911-kzwi1.

  DATA lv_dec4  TYPE p DECIMALS 4.

**Process only selected data
  t_9010x[] = t_9010[].
  lt_9010y[] = t_9010[].

  IF NOT p_crb IS INITIAL.    "not applicable for Reprint
    DELETE t_9010x WHERE select = '' OR
                         sts <> 'NEW'.
    DELETE lt_9010y WHERE
*                          select = 'X' AND
                          sts <> 'COR'.
    IF NOT lt_9010y[] IS INITIAL.
      SORT t_9010x BY ebeln.
      LOOP AT lt_9010y.
        CLEAR t_9010x.
        READ TABLE t_9010x WITH KEY ebeln = lt_9010y-ebeln
                           BINARY SEARCH.
        IF sy-subrc = 0.
          t_9010x = lt_9010y.
          APPEND t_9010x.
        ELSE.
          IF lt_9010y-select = 'X'.
            t_9010x = lt_9010y.
            t_9010x-xblnr = bkpf-xblnr.
            APPEND t_9010x.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR: t_9010x-no, t_9010-select.
  MODIFY t_9010x TRANSPORTING no select WHERE NOT no IS INITIAL.
  SORT t_9010x BY kunnr ekgart ekgrp bsart.

**Summarize all documents with following rule:
*****ONE ACC DOC FOR THE SAME CUSTOMER
*****THE LINE ITEM WILL BE EACH COST CENTER DEPENDING ON EKGRP,BSART
  LOOP AT t_9010x.
    CLEAR: t_kna1, t_t052,t_fp.
    MOVE-CORRESPONDING t_9010x TO lw_9010x.
    AT NEW kunnr.
      READ TABLE t_fp WITH KEY vbeln = lw_9010x-belnr.
      READ TABLE t_kna1 WITH KEY kunnr = t_9010x-kunnr
                        BINARY SEARCH.
      READ TABLE t_adrcz WITH KEY addrnumber = t_kna1-adrnr
                         BINARY SEARCH.
      READ TABLE t_t052 WITH KEY zterm = t_kna1-zterm
                                 BINARY SEARCH.
      MOVE-CORRESPONDING lw_9010x TO t_crb_head.
      MOVE-CORRESPONDING t_kna1 TO t_crb_head.
      t_crb_head-ztag1 = t_t052-ztag1.
      t_crb_head-street = t_adrcz-street.
*-----Faktur pajak number & date
      CLEAR: t_crb_head-fakno.
      IF NOT p_fp IS INITIAL OR
        p_faktu IS NOT INITIAL.
        t_crb_head-fakno = wa_fp-fakturno.
        t_crb_head-budat = wa_fp-fakdat.
      ENDIF.

      IF p_prt IS NOT INITIAL.
        IF t_fp-fakturno IS NOT INITIAL.
          t_crb_head-fakno = t_fp-fakturno.
          t_crb_head-budat = t_fp-fakdat.
        ENDIF.
      ENDIF.

      IF t_fp-bukrs = '8010' OR t_fp-bukrs = '8030' OR t_fp-bukrs = '8050' OR
         t_fp-bukrs = '8090' OR t_fp-bukrs = '8160' OR t_fp-bukrs = '8230' OR
         t_fp-bukrs = '8360'.
*        t_crb_head-name1 = t_fp-name.
*        t_crb_head-street = t_fp-addrs1.
*        t_crb_head-addrs2 = t_fp-addrs2.
*        t_crb_head-city = t_fp-city.
*        t_crb_head-postal = t_fp-postal.
        t_crb_head-name1 = t_adrcz-name_co.
        CONCATENATE t_adrcz-str_suppl1 t_adrcz-str_suppl2 INTO t_crb_head-street
          SEPARATED BY space.
        t_crb_head-addrs2 = t_adrcz-str_suppl3.
        t_crb_head-city = t_adrcz-location.
        t_crb_head-postal = t_adrcz-post_code1.
      ENDIF.

*      IF s_bukrs-low = '8330'.
      t_crb_head-name1 = t_adrcz-name_co.
      CONCATENATE t_adrcz-str_suppl1 t_adrcz-str_suppl2 INTO t_crb_head-street
        SEPARATED BY space.
      t_crb_head-addrs2 = t_adrcz-str_suppl3.
      t_crb_head-city = t_adrcz-location.
      t_crb_head-postal = t_adrcz-post_code1.
*      ENDIF.
    ENDAT.

    AT NEW ekgart.
      MOVE-CORRESPONDING lw_9010x TO t_crb_item.
    ENDAT.

    CASE 'X'.
      WHEN p_crb.
        PERFORM f_new_ppn11 USING bkpf-budat.
      WHEN OTHERS.
        PERFORM f_new_ppn11 USING t_crb_head-budat.
    ENDCASE.

****Calculate amount
    ld_kzwi1 = ld_kzwi1 + lw_9010x-kzwi1.

    AT END OF ekgart.
      t_crb_item-kzwi1 = ld_kzwi1.
      IF NOT ld_kzwi1 IS INITIAL.
        WRITE ld_kzwi1 CURRENCY t_crb_item-hwaer
              TO t_crb_item-numamt.

*------Get gross value for posting
        CLEAR : lv_dec4.
        lv_dec4 = ld_kzwi1 + ( ld_kzwi1 * d_tax / 100 ).

        PERFORM f_round_down USING lv_dec4
                             CHANGING t_crb_item-gross.

        WRITE t_crb_item-gross CURRENCY t_crb_item-hwaer
              TO ld_grossnum.
        t_crb_item-grossnum = ld_grossnum.

      ELSE.
        CLEAR: t_crb_item-numamt, t_crb_item-grossnum.
      ENDIF.
      APPEND t_crb_item.
      ld_tot = ld_tot + ld_kzwi1.
*      ld_grosstot = ld_grosstot + ld_grossnum.
      CLEAR: ld_kzwi1, ld_grossnum, t_crb_item.
    ENDAT.

    AT END OF kunnr.
      t_crb_head-kzwi1 = ld_tot.
      t_crb_head-grosstot = ld_grosstot.

*-----PPN amount
      CLEAR : lv_dec4.
      lv_dec4 = ld_tot * d_tax / 100.
      PERFORM f_round_down USING lv_dec4
                           CHANGING t_crb_head-amount_ppn.

*-----Total + PPN
      ld_amount = t_crb_head-amount_ppn + ld_tot.

*-----Get Materai value if only STKZU is ticked
      IF t_crb_head-stkzu = 'X'.
        LOOP AT t_fidt0002.
*-----Revise by Budi 31/08/2005
*          IF ld_tot GE t_fidt0002-range1 AND
*             ld_tot LE t_fidt0002-range2.
          IF ld_amount GE t_fidt0002-range1 AND
             ld_amount LE t_fidt0002-range2.
*-----End Revise by Budi 31/08/2005
            t_crb_head-amt_mt = t_fidt0002-value.
            IF NOT t_crb_head-amt_mt IS INITIAL.
              WRITE t_crb_head-amt_mt CURRENCY t_crb_head-hwaer
                    TO t_crb_head-matnum.
            ELSE.
              CLEAR t_crb_head-matnum.
            ENDIF.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR: t_crb_head-amt_mt, t_crb_head-matnum.
      ENDIF.

*-----Total fee + materai
      t_crb_head-total = t_crb_head-kzwi1 + t_crb_head-amt_mt.
      IF NOT t_crb_head-total IS INITIAL.
        WRITE t_crb_head-total CURRENCY t_crb_head-hwaer
              TO t_crb_head-numtot.
      ELSE.
        CLEAR t_crb_head-numtot.
      ENDIF.

*-----Total fee + materai + PPN
      t_crb_head-grossamt = t_crb_head-total + t_crb_head-amount_ppn.
      WRITE t_crb_head-grossamt CURRENCY t_crb_head-hwaer
            TO t_crb_head-grossnum.

*-----BUDAT & BLDAT
      IF NOT p_crb IS INITIAL.
        t_crb_head-budat = bkpf-budat.
        t_crb_head-bldat = bkpf-bldat.
      ENDIF.

*-----ZFBDT
      t_crb_head-zfbdt = t_crb_head-budat.

      APPEND t_crb_head.
      CLEAR: ld_tot, t_crb_head.
    ENDAT.

  ENDLOOP.

* Check VAT Date
  PERFORM f_check_vat_date.


ENDFORM.                    "f_process_selected_data

*&---------------------------------------------------------------------*
*&      Form  f_post_acc_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_acc_doc.

  DATA lt_update LIKE t_status OCCURS 0 WITH HEADER LINE.
  DATA lt_s911_update LIKE s911 OCCURS 0 WITH HEADER LINE.
  DATA ld_tabix LIKE sy-tabix.

**Post FB01
  IF NOT t_crb_head[] IS INITIAL.
    PERFORM f_bdc_fb01.
  ELSE.
    MESSAGE e000(zab) WITH 'No data to post'.
  ENDIF.

**Save to table and print if successful
  lt_update[] = t_status[].
  DELETE lt_update WHERE belnr = 'ERROR'.

*-Update S911 using Customer company code as key
  SORT lt_update BY bukrs_d.
  SORT t_ekkof BY ebeln.

  IF NOT lt_update[] IS INITIAL.
    LOOP AT t_9010x.
*-----Update Doc number
      CLEAR: lt_update, t_ekkof, t_konv, t_s911.
      READ TABLE lt_update WITH KEY bukrs_d = t_9010x-bukrs_d
                           BINARY SEARCH.
      IF sy-subrc = 0.
        t_s911-belnr = lt_update-belnr.
*        t_s911-stjah = sy-datum+(4).
        t_s911-stjah = bkpf-budat(4).
        t_s911-erfnam = sy-uname.
        t_s911-aedat = sy-datum.
        t_s911-budat = bkpf-budat.
        t_s911-bldat = bkpf-bldat.
        CLEAR t_s911-belnr_01.

*-------Update PO fee for foreign currency
        READ TABLE t_ekkof WITH KEY ebeln = t_9010x-ebeln BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE t_konv WITH KEY knumv = t_ekkof-knumv
                            BINARY SEARCH.
          IF sy-subrc = 0.
*------ Koreksi pengambilan fee koreksi 29/09/2005
*            IF t_9010x-kzwi1 < 0.
*              t_s911-kzwi1 = ( -1 ) * t_konv-kbetr.
*            ELSE.
*              t_s911-kzwi1 = t_konv-kbetr.
*            ENDIF.
* ----- Logic baru untuk fee koreksi
            IF t_9010x-vrsio EQ '000' AND
              t_9010x-netwr NE 0.
              IF t_9010x-kzwi1 < 0.
                t_s911-kzwi1 = ( -1 ) * t_konv-kbetr.
              ELSE.
                t_s911-kzwi1 = t_konv-kbetr.
              ENDIF.
            ELSE.
              READ TABLE t_s911 WITH KEY ebeln = t_9010x-ebeln
                                         vrsio = t_9010x-vrsio.
*                                BINARY SEARCH.
              IF sy-subrc EQ 0.
                t_s911-kzwi1 = t_s911-kzwi1.
                t_s911-belnr = lt_update-belnr.
*                t_s911-stjah = sy-datum+(4).
                t_s911-stjah = bkpf-budat(4).
                t_s911-erfnam = sy-uname.
                t_s911-aedat = sy-datum.
                t_s911-budat = bkpf-budat.
                t_s911-bldat = bkpf-bldat.
              ENDIF.
            ENDIF.

            MODIFY t_s911 TRANSPORTING belnr belnr_01 stjah budat bldat
                                       erfnam aedat kzwi1
                            WHERE bukrs = t_9010x-bukrs_d AND
                                  ekgrp = t_9010x-ekgrp AND
                                  bsart = t_9010x-bsart AND
                                  ebeln = t_9010x-ebeln AND
                                  vrsio = t_9010x-vrsio.
          ENDIF.
        ELSE.
          MODIFY t_s911 TRANSPORTING belnr belnr_01 stjah budat bldat
                                     erfnam aedat
                          WHERE bukrs = t_9010x-bukrs_d AND
                                ekgrp = t_9010x-ekgrp AND
                                bsart = t_9010x-bsart AND
                                ebeln = t_9010x-ebeln AND
                                vrsio = t_9010x-vrsio.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.

*---Update zero items to table
    IF NOT t_item_zero[] IS INITIAL.
      LOOP AT t_item_zero.
        CLEAR: lt_update, t_9010x, t_s911.
        READ TABLE lt_update WITH KEY bukrs_d = t_item_zero-bukrs_d
                             BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT t_9010x WHERE bukrs_d = lt_update-bukrs_d.
            READ TABLE t_s911 WITH KEY bukrs = t_9010x-bukrs_d
                                       ekgrp = t_9010x-ekgrp
                                       bsart = t_9010x-bsart
                                       ebeln = t_9010x-ebeln
                                       vrsio = t_9010x-vrsio.
            IF sy-subrc = 0 AND
               t_s911-belnr IS INITIAL.
              ld_tabix = sy-tabix.
              t_s911-belnr = lt_update-belnr.
*              t_s911-stjah = sy-datum+(4).
              t_s911-stjah = bkpf-budat(4).
              t_s911-erfnam = sy-uname.
              t_s911-aedat = sy-datum.
              t_s911-budat = bkpf-budat.
              t_s911-bldat = bkpf-bldat.
              MODIFY t_s911 INDEX ld_tabix TRANSPORTING belnr.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDLOOP.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lt_s911_update[] = t_s911[].
    DELETE lt_s911_update WHERE belnr IS INITIAL.

****Save to table S911
    IF NOT lt_s911_update[] IS INITIAL.
      UPDATE s911 FROM TABLE lt_s911_update.
      COMMIT WORK.

******Print Faktur
      IF p_crb EQ 'X'.
        IF bkpf-budat IN gr_coretax.
          IF bkpf-budat GE va_datab.
            PERFORM f_process_non_trade USING d_tnt_bukrs
                                              t_crb_head-belnr
                                              bkpf-budat+4(2)
                                              bkpf-budat(4)
                                        CHANGING va_fakno.
            IF va_fakno IS NOT INITIAL.
              PERFORM f_print_form.
            ELSE.
              PERFORM f_selected_period.
            ENDIF.
          ELSE.
            PERFORM f_print_form.
          ENDIF.
        ELSE.
          PERFORM f_print_form.
        ENDIF.
      ELSE.
        PERFORM f_print_form.
      ENDIF.
    ENDIF.
  ENDIF.

**Display Posting status report
  d_par = 'LOG'.

  PERFORM f_status_report.

ENDFORM.                    " f_post_acc_doc

*&---------------------------------------------------------------------*
*&      Form  f_bdc_fb01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM  f_bdc_fb01.

  DATA ld_bldat(8).
  DATA ld_budat(8).
  DATA ld_aufnr LIKE zgdfidt0001-aufnr.
  DATA ld_count TYPE i.
  DATA ld_hkont_rv LIKE zgdfist0002-hkont_rv.
  DATA ld_datum LIKE sy-datum.
  DATA ld_datum1(8).
  DATA ld_prepaid TYPE wrbtr.
  DATA ld_prepaid1(20).
  DATA ld_grossc(20).
  DATA lv_dec0  TYPE p DECIMALS 0.
  DATA ls_fidt0001  LIKE LINE OF t_fidt0001.
  DATA lv_sgtxt   TYPE bseg-sgtxt.

  ld_datum = bkpf-budat + t_crb_head-ztag1.

  PERFORM f_format_date USING    ld_datum
                        CHANGING ld_datum1.

  PERFORM f_format_date USING    bkpf-budat
                        CHANGING ld_budat.

  PERFORM f_format_date USING    bkpf-bldat
                        CHANGING ld_bldat.

***Eliminate item with zero value
  t_item_zero[] = t_crb_item[].
  DELETE t_item_zero WHERE NOT grossnum IS INITIAL.
  DELETE t_crb_item WHERE grossnum IS INITIAL.

***Generate error message if there are any negative value items
  t_minus[] = t_crb_item[].
  DELETE t_minus WHERE grossnum NS '-'.

***Don't execute if there are any negative value items
  IF NOT t_minus[] IS INITIAL.
    SORT t_minus BY kunnr.
    DELETE ADJACENT DUPLICATES FROM t_minus COMPARING kunnr.
    PERFORM f_popup_list USING 'F_WRITE_NEGATIVE_ITEMS'
                               'List of negative items'
                               10
                               5
                               60
                               10
                               'X'.
    LEAVE SCREEN.
  ELSE.
***Posting BDC
    LOOP AT t_crb_head.
      CLEAR: t_bdcdata, t_bdcmsg, t_status.
      CLEAR ld_count.
      REFRESH: t_bdcdata, t_bdcmsg.
      MOVE-CORRESPONDING t_crb_head TO t_status.

      CALL FUNCTION 'Z_PPN11'
        EXPORTING
          pi_calty = 'TC1'
          pi_datum = bkpf-budat
        IMPORTING
          po_mwskz = d_taxcode.

*      d_taxcode   = 'K2'.

      TRANSLATE t_crb_head-numtot USING '. '.
      CONDENSE t_crb_head-numtot NO-GAPS.

      ld_prepaid = ( t_crb_head-numtot * 2 ) / 100.
      WRITE ld_prepaid TO ld_prepaid1 CURRENCY 'IDR'.
      TRANSLATE ld_prepaid1 USING '. '.
      CONDENSE ld_prepaid1 NO-GAPS.
      ld_prepaid1 = ld_prepaid1 / 100.
      CONDENSE ld_prepaid1 NO-GAPS.

      CLEAR: lv_dec0.
      lv_dec0 = ld_prepaid1.
      ld_prepaid1 = lv_dec0.
      CONDENSE ld_prepaid1 NO-GAPS.

      "      PERFORM f_round_down USING lv_dec2
      "                     CHANGING ld_prepaid1.

      TRANSLATE t_crb_head-grossnum USING '. '.
      CONDENSE t_crb_head-grossnum NO-GAPS.

      ld_grossc  = t_crb_head-grossnum - lv_dec0.
      CONDENSE ld_grossc NO-GAPS.

*---Entering HEADER VALUE
      PERFORM f_bdc_data TABLES t_bdcdata USING:
                 'X' 'SAPMF05A'                '0100',
                 ' ' 'BDC_OKCODE'              '/00',
                 ' ' 'BKPF-BUKRS'              t_crb_head-bukrs,
                 ' ' 'BKPF-BLDAT'              ld_bldat,
                 ' ' 'BKPF-BUDAT'              ld_budat,
                 ' ' 'BKPF-BLART'              t_crb_head-blart,
                 ' ' 'BKPF-WAERS'              t_crb_head-hwaer,
                 ' ' 'BKPF-XBLNR'              bkpf-xblnr,
                 ' ' 'BKPF-BKTXT'              bkpf-bktxt,

*---Entering CUSTOMER VALUE
                 ' ' 'RF05A-NEWBS'             '01',
                 ' ' 'RF05A-NEWKO'             t_crb_head-kunnr,

                 'X' 'SAPMF05A'                '0301',
                 ' ' 'BDC_OKCODE'              '=ZK',
*               ' ' 'BSEG-WRBTR'              t_crb_head-numtot,
                 ' ' 'BSEG-WRBTR'              ld_grossc,   "t_crb_head-grossnum,
*                 ' ' 'BSEG-WMWST'              '0',
                 ' ' 'BKPF-XMWST'              'X',
                 ' ' 'BSEG-MWSKZ'              d_taxcode,
                 ' ' 'BSEG-GSBER'              t_crb_head-gsber,
*               ' ' 'BSEG-ZTERM'              t_crb_head-zterm,
                 ' ' 'BSEG-ZUONR'              bkpf-xblnr,
                 ' ' 'BSEG-SGTXT'              bkpf-bktxt,
                 ' ' 'BSEG-KIDNO'              bseg-kidno.

*---Entering MATERAI VALUE
      IF t_crb_head-stkzu = 'X' AND
         NOT t_crb_head-matnum IS INITIAL.
        ld_count = 1.
        PERFORM f_bdc_data TABLES t_bdcdata USING:
                   'X' 'SAPMF05A'                '0331',
                   ' ' 'BDC_OKCODE'              '/00',
                   ' ' 'RF05A-NEWBS'             '50',
                   ' ' 'RF05A-NEWKO'             t_crb_head-hkont_mt,

                   'X' 'SAPMF05A'                '0300',
                   ' ' 'BDC_OKCODE'              '=ZK',
                   ' ' 'BSEG-WRBTR'              t_crb_head-matnum,
                   ' ' 'BSEG-MWSKZ'              '',
                   ' ' 'BSEG-ZUONR'              bkpf-xblnr,
                   ' ' 'BSEG-SGTXT'              bkpf-bktxt,
                   ' ' 'BDC_SUBSCR'
                   'SAPLKACB                                0001BLOCK',
                   ' ' 'DKACB-FMORE'             'X',

                   'X' 'SAPLKACB'                '0002',
                   ' ' 'BDC_OKCODE'              '=ENTE',
                   ' ' 'COBL-GSBER'              t_crb_head-gsber,
                   ' ' 'COBL-KOSTL'              t_crb_head-kostl_mt,
                   ' ' 'COBL-PRCTR'              t_crb_head-prctr_mt,
*                 ' ' 'COBL-AUFNR'              d_aufnr_mat,
                   ' ' 'BDC_SUBSCR'
                   'SAPLKACB                                0003BLOCK1'.

      ENDIF.

*---Entering LINE ITEM VALUE (COST CENTER BASED)
      LOOP AT t_crb_item WHERE kunnr = t_crb_head-kunnr.
*---Ganti hkont rv jika kunnr ada di table ZGDFIDT0001A( Table mapping
*---untuk hkont ) 14/10/2005
        SELECT SINGLE hkont
          FROM zgdfidt0001a
          INTO ld_hkont_rv
          WHERE kunnr EQ t_crb_head-kunnr.
        IF sy-subrc EQ 0 AND ld_hkont_rv NE space.
          t_crb_item-hkont_rv = ld_hkont_rv.
        ENDIF.
*---End ganti

        ld_count = ld_count + 1.
        IF ld_count <> 1.
*         t_crb_head-stkzu = 'X' AND
*         NOT t_crb_head-matnum IS INITIAL.
          PERFORM f_bdc_data TABLES t_bdcdata USING:
                       'X' 'SAPMF05A'                '0330',
                       ' ' 'BDC_OKCODE'              '/00',
                       ' ' 'RF05A-NEWBS'             '50',
                       ' ' 'RF05A-NEWKO'             t_crb_item-hkont_rv.

        ELSE.
          PERFORM f_bdc_data TABLES t_bdcdata USING:
                       'X' 'SAPMF05A'                '0331',
                       ' ' 'BDC_OKCODE'              '/00',
                       ' ' 'RF05A-NEWBS'             '50',
                       ' ' 'RF05A-NEWKO'             t_crb_item-hkont_rv.
        ENDIF.

*-----Filling AUFNR
        CONCATENATE t_crb_item-aufnr t_crb_head-bukrs_d INTO ld_aufnr.

        CLEAR : ls_fidt0001, lv_sgtxt.
        READ TABLE t_fidt0001 INTO ls_fidt0001
                              WITH KEY ekgrp = t_crb_item-ekgrp
                                       bsart = t_crb_item-bsart.
        IF sy-subrc = 0.
          CONCATENATE 'Jasa Pembelian :' ls_fidt0001-txt1 INTO lv_sgtxt
          SEPARATED BY space.
        ENDIF.

        PERFORM f_bdc_data TABLES t_bdcdata USING:
                     'X' 'SAPMF05A'                '0300',
                     ' ' 'BDC_OKCODE'              '=ZK',
*                   ' ' 'BSEG-WRBTR'              t_crb_item-numamt,
                     ' ' 'BSEG-WRBTR'              t_crb_item-grossnum,
                     ' ' 'BSEG-MWSKZ'              d_taxcode,
                     ' ' 'BSEG-ZUONR'              bkpf-xblnr,
                     ' ' 'BSEG-SGTXT'              lv_sgtxt,  "bkpf-bktxt,
                     ' ' 'BDC_SUBSCR'
                    'SAPLKACB                                0001BLOCK',

                     'X' 'SAPLKACB'                '0002',
                     ' ' 'BDC_OKCODE'              '=ENTE',
                     ' ' 'COBL-GSBER'              t_crb_item-gsber,
                     ' ' 'COBL-KOSTL'              t_crb_item-kostl,
                     ' ' 'COBL-PRCTR'              t_crb_item-prctr,
                     ' ' 'COBL-AUFNR'              ld_aufnr,
*                   ' ' 'DKACB-XERGO'             'X',
                     ' ' 'BDC_SUBSCR'
                   'SAPLKACB                                0003BLOCK1'.

*                   'X' 'SAPLKEAK'                '0300',
*                   ' ' 'BDC_OKCODE'              '=WEIT'.

      ENDLOOP.

* Tambahan untuk prepaid
      PERFORM f_bdc_data TABLES t_bdcdata USING:
                   'X' 'SAPMF05A'                '0330',
                   ' ' 'BDC_OKCODE'              '/00',
                   ' ' 'RF05A-NEWBS'             '40',
                   ' ' 'RF05A-NEWKO'             '0142100020'.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
                   'X' 'SAPMF05A'                '0300',
                   ' ' 'BDC_OKCODE'              '=BU',
                   ' ' 'BSEG-WRBTR'              ld_prepaid1,
                   ' ' 'BSEG-ZFBDT'              ld_datum1,
                   ' ' 'BSEG-ZUONR'              bkpf-xblnr,
                   ' ' 'BSEG-SGTXT'              bkpf-bktxt.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
                   'X' 'SAPLKACB'                '0002',
                   ' ' 'BDC_OKCODE'              '=ENTE',
                   ' ' 'COBL-GSBER'              '1600'.

******---Simulate and Save
*****      PERFORM f_bdc_data TABLES t_bdcdata USING:
*****                   'X' 'SAPMF05A'                '0330',
*****                   ' ' 'BDC_OKCODE'              '=BS',
*****
*****                   'X' 'SAPMF05A'                '0700',
*****                   ' ' 'BDC_OKCODE'              '=BU',
*****                   ' ' 'BKPF-XBLNR'              bkpf-xblnr,
*****                   ' ' 'BKPF-BKTXT'              bkpf-bktxt.

      d_bdc_tctxt = 'Executing Transaction FB01'.
      IF p_upd = 'X'.
        d_bdc_batch = 'A'.
      ELSE.
        d_bdc_batch = 'N'.
      ENDIF.
      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'FB01' d_bdc_tctxt.

****Get Document number if successfully created
      IF d_bdc_error = 0.
        MOVE t_bdcmsg-msgv1 TO t_status-belnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_status-belnr
          IMPORTING
            output = t_status-belnr.
        t_status-icon = icon_led_green.

*-----update document number to be printed
        t_crb_head-belnr = t_status-belnr.

*        IF bkpf-budat GE va_datab.
*          PERFORM f_process_non_trade USING d_tnt_bukrs
*                                            t_crb_head-belnr
*                                            bkpf-budat+4(2)
*                                            bkpf-budat(4)
*                                      CHANGING va_fakno.
*        ENDIF.
        MODIFY t_crb_head TRANSPORTING belnr.
      ELSE.
        t_status-belnr = 'ERROR'.
        t_status-icon = icon_led_red.
      ENDIF.

****Get message
      PERFORM f_get_message USING t_bdcmsg
                            CHANGING t_status-msg.
      APPEND t_status.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_bdc_fb01

*&---------------------------------------------------------------------*
*&      Form  f_save_to_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table.

ENDFORM.                    " f_save_to_table

*&---------------------------------------------------------------------*
*&      Form  f_print_faktur
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_faktur.

ENDFORM.                    " f_print_faktur

*&---------------------------------------------------------------------*
*&      Form  f_status_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_status_report.

  PERFORM f_alv TABLES t_status.

ENDFORM.                    " f_status_report

*&---------------------------------------------------------------------*
*&      Form  f_get_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_po.

  DATA ld_kunnr LIKE kna1-kunnr.
  DATA ld_uname LIKE sy-uname.

**Get PO for correction
  SELECT SINGLE * FROM s911
           WHERE ebeln = p_ebeln AND
                 vrsio = p_vrsio AND
                 belnr <> '' AND
                 kzwi1 <> 0.
  IF sy-subrc <> 0.
    MESSAGE i000(zab) WITH 'Data not found'.
    STOP.
  ELSE.
*---Lock object
    PERFORM f_lock_s911_rec USING s911
                            CHANGING ld_uname.
    IF NOT ld_uname IS INITIAL.
      MESSAGE i000(zab) WITH 'PO' s911-ebeln
                             'is locked by' ld_uname.
      STOP.
    ENDIF.

*---Get last version
    SELECT * INTO TABLE t_vrsio
             FROM s911
             WHERE ebeln = p_ebeln.
    IF sy-subrc = 0.
      SORT t_vrsio BY vrsio DESCENDING.
    ENDIF.
  ENDIF.

**Get Customer data from Company code table
  SELECT SINGLE * FROM t001
         WHERE bukrs = s911-bukrs.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM adrc
           WHERE addrnumber = t001-adrnr.
    IF sy-subrc <> 0 OR adrc-sort2 IS INITIAL.
      MESSAGE i000(zab) WITH 'Please maintain customer number'
                             'for selected company codes'.
      STOP.
    ENDIF.
  ENDIF.

**Get Config data
  SELECT SINGLE * FROM zgdfidt0001
           WHERE ekgrp = s911-ekgrp AND
                 bsart = s911-bsart.

**Get PO data
  SELECT SINGLE * FROM ekko
         WHERE ebeln = p_ebeln.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM lfa1
           WHERE lifnr = ekko-lifnr.
  ENDIF.

****Get Further Customer data
  ld_kunnr = adrc-sort2.
  IF NOT ld_kunnr IS INITIAL.
    SELECT SINGLE * FROM kna1
           WHERE kunnr = ld_kunnr.
  ENDIF.

**Currency key
  d_hwaer1 = d_hwaer2 = d_hwaer3 = s911-hwaer.

ENDFORM.                    " f_get_po

*&---------------------------------------------------------------------*
*&      Form  f_save_po_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_po_change.

  DATA ld_vrsio TYPE i.
  DATA ld_mod TYPE i.
  DATA ld_num(3) TYPE n.
  DATA ld_vrsio1 LIKE s911-vrsio.

  CLEAR: t_s911, t_s911[].

**Get last version
  READ TABLE t_vrsio INDEX 1.
  MOVE p_vrsio TO ld_vrsio.
  ld_mod = ld_vrsio MOD 2.

  CASE p_vrsio.
    WHEN '000'.
      t_s911 = s911.
      CLEAR t_s911-belnr.
      APPEND t_s911.
      t_s911 = s911.
*      t_s911-vrsio = '001'.
      ld_num = t_vrsio-vrsio + 1.
      t_s911-vrsio = ld_num.
      APPEND t_s911.
      t_s911 = s911.
*      t_s911-vrsio = '002'.
      ld_num = t_vrsio-vrsio + 2.
      t_s911-vrsio = ld_num.
      t_s911-netwr = ( -1 ) * d_netwr.
      t_s911-kzwi1 = ( -1 ) * d_kzwi1.
      CLEAR: t_s911kor,ld_vrsio1,ld_num.
      MOVE-CORRESPONDING t_s911 TO t_s911kor.
      SELECT MAX( vrsio ) INTO ld_vrsio1 FROM zs911kor
        WHERE spmon = t_s911kor-spmon  AND
              bukrs = t_s911kor-bukrs  AND
              ekgrp = t_s911kor-ekgrp  AND
              bsart = t_s911kor-bsart  AND
              ebeln = t_s911kor-ebeln.
      IF ld_vrsio1 IS NOT INITIAL.
        ld_num = ld_vrsio1.
        ld_num = ld_num + 1.
        ld_vrsio1 = ld_num.
        t_s911kor-vrsio = ld_vrsio1.
      ENDIF.
      t_s911kor-zuser = sy-uname.
      t_s911kor-zdate = sy-datum.
*      t_s911kor-kode = p_kode.
      t_s911kor-ztext1 = p_text1.
      t_s911kor-ztext2 = p_text2.
      t_s911kor-ztext3 = p_text3.
      CLEAR t_s911-belnr.
      APPEND t_s911.
      APPEND t_s911kor.
      MODIFY zs911kor FROM TABLE t_s911kor.
      MODIFY s911 FROM TABLE t_s911.
    WHEN OTHERS.
      CASE ld_mod.
        WHEN 0.
          s911-netwr = ( -1 ) * d_netwr.
          s911-kzwi1 = ( -1 ) * d_kzwi1.
          UPDATE s911.
          CLEAR: t_s911kor,ld_vrsio,ld_num.
          MOVE-CORRESPONDING t_s911 TO t_s911kor.
          SELECT MAX( vrsio ) INTO ld_vrsio FROM zs911kor
            WHERE spmon = t_s911kor-spmon  AND
                  bukrs = t_s911kor-bukrs  AND
                  ekgrp = t_s911kor-ekgrp  AND
                  bsart = t_s911kor-bsart  AND
                  ebeln = t_s911kor-ebeln.
          IF ld_vrsio IS NOT INITIAL.
            ld_num = ld_vrsio.
            ld_num = ld_num + 1.
            ld_vrsio = ld_num.
            t_s911kor-vrsio = ld_vrsio.
          ENDIF.
        WHEN OTHERS.
          MESSAGE i000(zab) WITH 'Correction is not possible'.
          LEAVE TO SCREEN 0.
*          STOP.
      ENDCASE.
  ENDCASE.

ENDFORM.                    " f_save_po_change

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

  READ TABLE t_user INDEX 1.
  CASE t_user-datfm.
    WHEN 'DD.MM.YYYY'.
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat(4)
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat(4)
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date

*&---------------------------------------------------------------------*
*&      Form  F_PAGING
*&---------------------------------------------------------------------*
*&  This routine performs PAGE UP/DOWN functionalities on the screen
*&---------------------------------------------------------------------*
*&  ->FU_CODE  - User command
*&---------------------------------------------------------------------*
FORM f_paging USING fu_code.

  DATA: ld_i TYPE i,
        ld_j TYPE i.

  CASE fu_code.
    WHEN 'P--'.
      tc_9010-top_line = 1.
    WHEN 'P-'.
      tc_9010-top_line = tc_9010-top_line - d_line_count.
      IF tc_9010-top_line LE 0.
        tc_9010-top_line = 1.
      ENDIF.
    WHEN 'P+'.
      ld_i = tc_9010-top_line + d_line_count.
      ld_j = tc_9010-lines - d_line_count + 1.
      IF ld_j LE 0.
        ld_j = 1.
      ENDIF.
      IF ld_i LE ld_j.
        tc_9010-top_line = ld_i.
      ELSE.
        tc_9010-top_line = ld_j.
      ENDIF.
    WHEN 'P++'.
      tc_9010-top_line = tc_9010-lines - d_line_count + 1.
      IF tc_9010-top_line LE 0.
        tc_9010-top_line = 1.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_PAGING

*&---------------------------------------------------------------------*
*&      Form  f_save_print_counter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_print_counter.

  DATA lt_print LIKE t_status OCCURS 0 WITH HEADER LINE.
  DATA lt_s911_print LIKE t_s911 OCCURS 0 WITH HEADER LINE.

  lt_print[] = t_status[].
  DELETE lt_print WHERE belnr = 'ERROR'.
  IF NOT lt_print[] IS INITIAL.
    LOOP AT t_9010x.
      READ TABLE lt_print WITH KEY bukrs_d = t_9010x-bukrs_d
                           BINARY SEARCH.
      LOOP AT t_s911 WHERE bukrs = t_9010x-bukrs_d AND
                           ekgrp = t_9010x-ekgrp AND
                           bsart = t_9010x-bsart AND
                           ebeln = t_9010x-ebeln AND
                           vrsio = t_9010x-vrsio.

        t_s911-aplzl = t_s911-aplzl + 1.
        MODIFY t_s911 TRANSPORTING aplzl.
      ENDLOOP.
    ENDLOOP.

    lt_s911_print[] = t_s911[].
    DELETE lt_s911_print WHERE belnr IS INITIAL.

****Save to table S911
    IF NOT lt_s911_print[] IS INITIAL.
      UPDATE s911 FROM TABLE lt_s911_print.
      COMMIT WORK.

    ENDIF.
  ENDIF.

ENDFORM.                    " f_save_print_counter

*&---------------------------------------------------------------------*
*&      Form  f_reverse_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reverse_doc.

  DATA ld_answer.
  DATA ld_text2(50).

  CONCATENATE 'Document' p_belnr 'year' p_stjah
              'will be reversed.'
              INTO ld_text2
              SEPARATED BY space.

  PERFORM f_popup_to_confirm_step
          USING    'Reverse document'
                   ld_text2
                   'Are you sure to reverse this document?'
          CHANGING ld_answer.
  CASE ld_answer.
    WHEN 'J'.
      CLEAR ld_answer.
      PERFORM f_fb08.
    WHEN OTHERS.
      CLEAR ld_answer.
  ENDCASE.

ENDFORM.                    " f_reverse_doc

*&---------------------------------------------------------------------*
*&      Form  f_fb08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fb08.

  DATA ld_belnr LIKE s911-belnr.
  DATA ld_bukrs LIKE s911-bukrs.
  DATA ld_msg(50).
  DATA ld_vrsio LIKE s911-vrsio.
  DATA ld_num(3) TYPE n.

  IF NOT t_s911[] IS INITIAL.
*    SORT t_s911 BY bukrs belnr stjah.
    SORT t_s911 BY belnr stjah.
    READ TABLE t_s911 WITH KEY
*                               bukrs = p_bukrs
                               belnr = p_belnr
                               stjah = p_stjah
                               BINARY SEARCH.
    IF sy-subrc = 0.
      SELECT SINGLE bukrs INTO ld_bukrs
                          FROM zgdfidt0001
                          WHERE ekgrp = t_s911-ekgrp AND
                                bsart = t_s911-bsart.
      IF sy-subrc <> 0.
        MESSAGE i000(zab) WITH 'Please update Mapping table first'.
        STOP.
      ENDIF.

      CLEAR: t_bdcdata, t_bdcmsg, t_status.
      REFRESH: t_bdcdata, t_bdcmsg.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
                 'X' 'SAPMF05A'                '0105',
                 ' ' 'BDC_OKCODE'              '=BU',
                 ' ' 'RF05A-BELNS'             t_s911-belnr,
                 ' ' 'BKPF-BUKRS'              ld_bukrs,
                 ' ' 'RF05A-GJAHS'             t_s911-stjah,
                 ' ' 'UF05A-STGRD'             '01'.

      d_bdc_tctxt = 'Executing Transaction FB08'.
      IF p_upd = 'X'.
        d_bdc_batch = 'A'.
      ELSE.
        d_bdc_batch = 'N'.
      ENDIF.
      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'FB08' d_bdc_tctxt.

****--Get message
      PERFORM f_get_message USING t_bdcmsg
                            CHANGING ld_msg.

****--Get Document number if successfully created
      IF d_bdc_error = 0.
        MOVE t_bdcmsg-msgv1 TO ld_belnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ld_belnr
          IMPORTING
            output = ld_belnr.

****----Update internal table
***** Tambahan untuk update table ZS911Kor
*** Jika terjadi Reverse dan Correction PO

        t_s911-belnr_01 = ld_belnr.
        CLEAR: t_s911kor, ld_vrsio.
        MOVE-CORRESPONDING t_s911 TO t_s911kor.
        SELECT MAX( vrsio ) INTO ld_vrsio FROM zs911kor
          WHERE spmon = t_s911kor-spmon  AND
                bukrs = t_s911kor-bukrs  AND
                ekgrp = t_s911kor-ekgrp  AND
                bsart = t_s911kor-bsart  AND
                ebeln = t_s911kor-ebeln.
        IF ld_vrsio IS NOT INITIAL.
          ld_num = ld_vrsio.
          ld_num = ld_num + 1.
          ld_vrsio = ld_num.
          t_s911kor-vrsio = ld_vrsio.
        ENDIF.
        t_s911kor-zuser = sy-uname.
        t_s911kor-zdate = sy-datum.
*        t_s911kor-kode  = p_zkode.
        t_s911kor-ztext1  = p_ztext1.
        t_s911kor-ztext2  = p_ztext2.
        t_s911kor-ztext3  = p_ztext3.
        APPEND t_s911kor.
        MODIFY zs911kor FROM TABLE t_s911kor.

**** End Update
        CLEAR t_s911-belnr.
        MODIFY t_s911 TRANSPORTING belnr belnr_01
                      WHERE belnr_01 IS INITIAL.

*-------Update database table
        UPDATE s911 FROM TABLE t_s911.
        COMMIT WORK.
        CLEAR: t_s911kor. REFRESH: t_s911kor.
      ENDIF.
    ENDIF.

    IF d_bdc_error = 0.
      MESSAGE s000(zab) WITH ld_msg.
    ELSE.
      MESSAGE i000(zab) WITH ld_msg.
    ENDIF.

  ENDIF.

ENDFORM.                                                    " f_fb08

*&---------------------------------------------------------------------*
*&      Form  f_lock_s911_rec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_s911_rec USING fu_s911 LIKE s911
                     CHANGING fc_uname.

  DATA ld_lockuser LIKE sy-uname.

  CALL FUNCTION 'ENQUEUE_EMEKKOE'
    EXPORTING
      mode_ekko      = 'E'
*     mode_ekpo      = i_mode
      ebeln          = fu_s911-ebeln
*     ebelp          = i_ebelp
*     _wait          = i_wait
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

*  CALL FUNCTION 'ENQUEUE_EZGD_S911'
*   EXPORTING
*     mode_s911            = 'E'
*     mandt                = sy-mandt
*     spmon                = fu_s911-spmon
*     bukrs                = fu_s911-bukrs
*     ekgrp                = fu_s911-ekgrp
*     bsart                = fu_s911-bsart
*     bedat                = fu_s911-bedat
*     ebeln                = fu_s911-ebeln
*     vrsio                = fu_s911-vrsio
*     sptag                = fu_s911-sptag
*     spwoc                = fu_s911-spwoc
*     spbup                = fu_s911-spbup
*     ssour                = fu_s911-ssour
*   EXCEPTIONS
*     foreign_lock         = 1
*     system_failure       = 2
*     OTHERS               = 3
*            .

  IF sy-subrc <> 0.
    ld_lockuser = sy-msgv1.
    IF sy-subrc = 1.
      fc_uname = ld_lockuser.
    ELSE.
      MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CLEAR fc_uname.
  ENDIF.

ENDFORM.                    " f_lock_s911_rec

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*&  This routine pops up a confirmation windows whenever user decide
*&  to exit the program/transaction
*&---------------------------------------------------------------------*
*&  ->FU_TITLE     - Popup title
*&  ->FU_TEXT1     - Popup text 1
*&  ->FU_TEXT2     - Popup text 2
*&  <-FC_ANSWER    - User action
*&---------------------------------------------------------------------*
FORM f_popup_to_confirm_step USING  fu_title
                                    fu_text1
                                    fu_text2
                           CHANGING fc_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = 'N'
      textline1      = fu_text1
      textline2      = fu_text2
      titel          = fu_title
      start_column   = 25
      start_row      = 6
      cancel_display = 'X'
    IMPORTING
      answer         = fc_answer
    EXCEPTIONS
      OTHERS         = 1.

ENDFORM.                               " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*&      Form  f_get_printer_def
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_printer_def USING fu_uname
                       CHANGING fc_print.

  CLEAR fc_print.
  SELECT SINGLE spld INTO fc_print
                     FROM usr01
                     WHERE bname = fu_uname.

ENDFORM.                    " f_get_printer_def

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc1 USING    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
*  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  l_tc_lines_name = 'D_LINE_COUNT'.
  ASSIGN (l_tc_lines_name) TO <lines>.

* is no line filled?                                                   *
  IF <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*     set actual column                                                *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.

ENDFORM.                              " COMPUTE_SCROLLING_IN_TC1

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
* execute general and TC specific operations                           *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

* get current line
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*   set top line and new cursor line                                   *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
      l_line = 1.
    ELSE.
      <tc>-top_line = 1.
      l_line = l_selline.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
*   set top line and new cursor line                                   *
    l_lastline = l_selline + <lines> - 1.
    IF l_lastline <= <tc>-lines.
      <tc>-top_line = l_selline.
      l_line = 1.
    ELSEIF <lines> > <tc>-lines.
      <tc>-top_line = 1.
      l_line = l_selline.
    ELSE.
      <tc>-top_line = <tc>-lines - <lines> + 2 .
      l_line = l_selline - <tc>-top_line + 1.
    ENDIF.
  ENDIF.
* insert initial line
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


* is no line filled?                                                   *
  IF <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*     set actual column                                                *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  f_get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUKRS  text
*      -->FU_WERKS  text
*      -->FU_KUNNR  text
*      <--FC_BUTXT  text
*      <--FC_NAMEW  text
*      <--FC_NAMEC  text
*----------------------------------------------------------------------*
FORM f_get_text USING    fu_bukrs
                         fu_werks
                         fu_kunnr
                CHANGING fc_butxt
                         fc_namew
                         fc_namec.

  DATA ld_adrnr LIKE adrc-addrnumber.

*-Company code
  SELECT SINGLE butxt INTO fc_butxt
                      FROM t001
                      WHERE bukrs = fu_bukrs.

*-Plant
  CLEAR ld_adrnr.
  SELECT SINGLE adrnr INTO ld_adrnr
                      FROM t001w
                      WHERE werks = fu_werks.
  SELECT SINGLE name1 INTO fc_namew
                      FROM adrc
                      WHERE addrnumber = ld_adrnr.

*-Customer
  CLEAR ld_adrnr.
  SELECT SINGLE adrnr INTO ld_adrnr
                      FROM kna1
                      WHERE kunnr = fu_kunnr.
  SELECT SINGLE name1 INTO fc_namec
                      FROM adrc
                      WHERE addrnumber = ld_adrnr.



ENDFORM.                    " f_get_text

*&---------------------------------------------------------------------*
*&      Form  f_check_link_cc_plant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_link_cc_plant.

  DATA ld_cn TYPE i.
  DATA ld_bukrs LIKE t001-bukrs.

  CLEAR: zgdfidt0003, ld_cn, d_kunnr.
  SELECT * FROM zgdfidt0003
           INTO TABLE t_fidt0003
           WHERE bukrs = s_bukrs-low AND
                 werks = s_werks-low.
  IF sy-subrc <> 0.
*---------Not exist means the customer is uniquely assigned to the
*---------customer code & plant, maintained in Company code text
*    CALL FUNCTION 'CO_RM_COMPANYCODE_FIND'
*         EXPORTING
*              werks    = s_werks-low
*         IMPORTING
*              compcode = ld_bukrs
*         EXCEPTIONS
*              no_entry = 1
*              OTHERS   = 2.
*    IF sy-subrc <> 0.
*      MESSAGE i000(zab)
*              WITH 'Company code does not match with Plant'.
*      STOP.
*    ELSE.
*      IF s_bukrs-low <> ld_bukrs.
*        MESSAGE i000(zab)
*                WITH 'Company code does not match with Plant'.
*        STOP.
*      ENDIF.
*    ENDIF.
    EXIT.
  ELSE.
*---------ZGDFIDT0003 only stores Company with multiple assigned
*---------customer number
    SORT t_fidt0003 BY bukrs werks.
    DESCRIBE TABLE t_fidt0003 LINES ld_cn.
    IF ld_cn = 1.
      READ TABLE t_fidt0003 INDEX 1.
      d_kunnr = t_fidt0003-kunnr.
      PERFORM f_get_text USING    t_fidt0003-bukrs
                                  t_fidt0003-werks
                                  t_fidt0003-kunnr
                         CHANGING t_fidt0003-butxt
                                  t_fidt0003-namew
                                  t_fidt0003-namec.
      MODIFY t_fidt0003 INDEX 1 TRANSPORTING butxt namew namec.

    ELSE.
      CLEAR d_kunnr.
      LOOP AT t_fidt0003.
        PERFORM f_get_text USING    t_fidt0003-bukrs
                                    t_fidt0003-werks
                                    t_fidt0003-kunnr
                           CHANGING t_fidt0003-butxt
                                    t_fidt0003-namew
                                    t_fidt0003-namec.
        MODIFY t_fidt0003 TRANSPORTING butxt namew namec.
      ENDLOOP.
      CALL SCREEN 9030 STARTING AT 10 10 ENDING AT 100 20.
    ENDIF.

    IF t_fidt0003[] IS NOT INITIAL.
      SELECT *
        FROM zgdtxdt0025
        INTO CORRESPONDING FIELDS OF TABLE gt_0025
        FOR ALL ENTRIES IN t_fidt0003
        WHERE kunnr = t_fidt0003-kunnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_check_link_cc_plant

*&---------------------------------------------------------------------*
*&      Form  f_get_customer_from_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUKRS  text
*      -->FT_BELNR  text
*----------------------------------------------------------------------*
FORM f_get_customer_from_bseg TABLES   ft_belnr STRUCTURE t_s911
                              USING    fu_bukrs.

  DATA lt_belnr LIKE t_s911 OCCURS 0 WITH HEADER LINE.

  lt_belnr[] = ft_belnr[].
  SORT lt_belnr BY belnr stjah.
  DELETE lt_belnr WHERE belnr IS INITIAL.
  IF NOT lt_belnr[] IS INITIAL.

    DELETE ADJACENT DUPLICATES FROM lt_belnr
           COMPARING belnr stjah.
    SELECT belnr gjahr bktxt xblnr
           INTO TABLE t_bkpf
           FROM bkpf
           FOR ALL ENTRIES IN lt_belnr
           WHERE bukrs = fu_bukrs AND
                 belnr = lt_belnr-belnr AND
                 gjahr = lt_belnr-stjah.

    SELECT belnr gjahr buzei kunnr kidno
           INTO TABLE t_bseg
           FROM bseg
           FOR ALL ENTRIES IN lt_belnr
                     WHERE bukrs = fu_bukrs AND
                           belnr = lt_belnr-belnr AND
                           gjahr = lt_belnr-stjah AND
                           kunnr <> ''.

*---Get additional data from tax table
    SELECT a~fakturno a~fakdat
           b~vbeln b~gjahr b~form
           a~bukrs a~name a~addrs1 a~addrs2 a~city a~postal
           INTO CORRESPONDING FIELDS OF TABLE t_fp
           FROM zgdtxdt0003 AS a JOIN zgdtxdt0002 AS b
           ON a~bukrs = b~bukrs AND
              a~brnch = b~brnch AND
              a~busln = b~busln AND
              a~fakturno = b~fakturno
           FOR ALL ENTRIES IN lt_belnr
           WHERE a~bukrs = fu_bukrs AND
                 a~batal = '' AND
                 b~vbeln = lt_belnr-belnr AND
                 b~gjahr = lt_belnr-stjah.
    IF sy-subrc = 0.
      IF NOT p_rev IS INITIAL.
        MESSAGE i000(zab) WITH 'Document cannot be reversed.'
                               'Faktur pajak has been issued.'.
        STOP.
      ENDIF.
      SORT t_fp BY vbeln gjahr.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_get_customer_from_bseg

*&---------------------------------------------------------------------*
*&      Form  f_save_po_special
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_po_special.

  DATA lw_s911 LIKE s911.
  DATA ld_answer.

*--Fill up other key fields (default)
  s911-spmon = sy-datum(6).
  s911-vrsio = '000'.
  s911-erfnam = sy-uname.
  s911-aedat = sy-datum.

  SELECT SINGLE * INTO lw_s911
         FROM s911
         WHERE
*               spmon = s911-spmon AND
               bukrs = s911-bukrs AND
               ekgrp = s911-ekgrp AND
               bsart = s911-bsart AND
*               bedat = s911-bedat AND
               ebeln = s911-ebeln.
*               vrsio = s911-vrsio.
  IF sy-subrc = 0.
    IF lw_s911-belnr IS INITIAL.
      IF lw_s911-netwr <> s911-netwr OR
         lw_s911-kzwi1 <> s911-kzwi1.
        PERFORM f_popup_to_confirm_step
                USING    'Change document'
                         'PO Document already exist.'
                         'Are you sure to change this document?'
                CHANGING ld_answer.
        d_mess = ld_answer.
        CASE ld_answer.
          WHEN 'J'.
            CLEAR ld_answer.
            lw_s911-netwr = s911-netwr.
            lw_s911-kzwi1 = s911-kzwi1.
            lw_s911-erfnam = sy-uname.
            lw_s911-aedat = sy-datum.
            s911 = lw_s911.
            UPDATE s911.
            PERFORM f_zgdfidt0005 USING 'U' lw_s911.
          WHEN OTHERS.
            CLEAR ld_answer.
        ENDCASE.
      ELSE.
        MESSAGE e000(zab) WITH 'PO already exist with the same value'.
      ENDIF.
    ELSE.
      MESSAGE e000(zab) WITH 'Billing has been created for the PO.'
                             'PO cannot be changed anymore'.
    ENDIF.
  ELSE.
    INSERT s911.
    PERFORM f_zgdfidt0005 USING 'I' lw_s911.
  ENDIF.

ENDFORM.                    " f_save_po_special

*&---------------------------------------------------------------------*
*&      Form  f_display_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_lock.

  PERFORM f_popup_list USING 'F_WRITE_LOCKED_PO'
                             'List of locked PO'
                             10
                             5
                             50
                             10
                             'X'.

ENDFORM.                    " f_display_lock

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_LIST
*&---------------------------------------------------------------------*
*&  This routine displays log in popup screen
*&---------------------------------------------------------------------*
FORM f_popup_list
     USING fu_form
           fu_title
           fu_col
           fu_row
           fu_width
           fu_height
           fu_flag_show_print_button.

  DATA: ld_formname(30) TYPE c,
        ld_repid        LIKE sy-repid.

  ld_formname = fu_form.
  TRANSLATE ld_formname TO UPPER CASE.
  ld_repid = sy-repid.

  CALL FUNCTION 'C14A_POPUP_LIST_DISPLAY'
    EXPORTING
      i_callback              = ld_formname
      i_callback_program      = ld_repid
      i_title                 = fu_title
      i_col                   = fu_col
      i_row                   = fu_row
      i_width                 = fu_width
      i_height                = fu_height
      i_flg_show_print_button = fu_flag_show_print_button
    EXCEPTIONS
      no_callback_specified   = 1
      OTHERS                  = 2.
ENDFORM.                    " F_POPUP_ERROR_LIST

*---------------------------------------------------------------------*
*       FORM f_write_locked_po                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_locked_po.

  LOOP AT t_lock.
    WRITE: / icon_locked AS ICON,
             'PO ', t_lock-ebeln, ' is locked by ', t_lock-uname.
  ENDLOOP.

ENDFORM.                    "f_write_locked_po

*---------------------------------------------------------------------*
*       FORM F_WRITE_NEGATIVE_ITEMS                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_negative_items.

  LOOP AT t_minus.
    WRITE: / icon_led_red AS ICON,
             'Item for customer ', t_minus-kunnr, ' has negative value'.
  ENDLOOP.

ENDFORM.                    "f_write_negative_items

*&---------------------------------------------------------------------*
*&      Form  f_get_signature
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_signature.

  DATA lw_zgdtxdt0005 LIKE zgdtxdt0005.

***Get signature
  SELECT SINGLE petugas jabat petugas2 jabat2 nameadm jabatadm brnch objrange
         INTO CORRESPONDING FIELDS OF lw_zgdtxdt0005
         FROM zgdtxdt0005
         WHERE bukrs = d_tnt_bukrs.
  IF sy-subrc = 0.
    d_petugas1 = lw_zgdtxdt0005-petugas.
    d_jabat1 = lw_zgdtxdt0005-jabat.
    d_petugas2 = lw_zgdtxdt0005-petugas2.
    d_jabat2 = lw_zgdtxdt0005-jabat2.
    d_petugas3 = lw_zgdtxdt0005-nameadm.
    d_jabat3 = lw_zgdtxdt0005-jabatadm.
    d_brnch = lw_zgdtxdt0005-brnch.
    d_object  = lw_zgdtxdt0005-objrange.
  ELSE.
*    MESSAGE i000(zab) WITH 'Signature data is not maintained'.
*    STOP.
  ENDIF.

ENDFORM.                    " f_get_signature

*---------------------------------------------------------------------*
*       FORM f_popup_signer                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_popup_signer CHANGING fc_petugas
                             fc_jabat.

  DATA ld_result.

  CALL FUNCTION 'K_KKB_POPUP_RADIO3'
    EXPORTING
      i_title   = 'Signed by:'
      i_text1   = d_petugas1
      i_text2   = d_petugas3
      i_text3   = d_petugas2
      i_default = '1'
    IMPORTING
      i_result  = ld_result
    EXCEPTIONS
      cancel    = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
*    LEAVE TO SCREEN 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CASE ld_result.
      WHEN '1'.
        fc_petugas = d_petugas1.
        fc_jabat = d_jabat1.
      WHEN '2'.
        fc_petugas = d_petugas3.
        fc_jabat = d_jabat3.
      WHEN '3'.
        fc_petugas = d_petugas2.
        fc_jabat = d_jabat2.
    ENDCASE.
  ENDIF.

ENDFORM.                    "f_popup_signer

*&---------------------------------------------------------------------*
*&      Form  f_proses_report_kor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_report_kor .
  DATA ld_cust_flag.
  DATA lt_cust LIKE t_adrc OCCURS 1 WITH HEADER LINE.
  DATA sw      TYPE i.
  DATA: l_ebelp  LIKE ekpo-ebelp.
  DATA ld_no LIKE t_9010-no.
  DATA lt_ekko LIKE t_ekko OCCURS 0 WITH HEADER LINE.
  DATA ld_ekpo.
  DATA ld_uname LIKE sy-uname.
  DATA lt_kunnr LIKE t_9010 OCCURS 0 WITH HEADER LINE.
  DATA lt_kna1x LIKE t_kna1 OCCURS 0 WITH HEADER LINE.

  IF p_rev IS INITIAL. "no need to process for REVERSE
**--Get Customer data from Company code table
    SELECT bukrs butxt adrnr
           INTO TABLE t_t001
           FROM t001
           WHERE bukrs IN s_bukrs.
    IF sy-subrc = 0.
      SORT t_t001 BY bukrs.
      SELECT addrnumber sort2
             INTO TABLE t_adrc
             FROM adrc
             FOR ALL ENTRIES IN t_t001
             WHERE addrnumber = t_t001-adrnr.
      SORT t_adrc BY addrnumber.
      IF sy-subrc <> 0.
        MESSAGE i000(zab) WITH 'Please maintain customer number'
                               'for selected company codes'.
        STOP.
      ENDIF.
    ENDIF.

**--Check customer data
    IF p_crb = 'X'.
      READ TABLE t_fidt0003 WITH KEY bukrs = s_bukrs-low
                                     werks = s_werks-low
                                     BINARY SEARCH.
      IF sy-subrc = 0.
        ld_cust_flag = 'X'.  "customer is more than one
      ELSE.
        CLEAR ld_cust_flag.
        lt_cust[] = t_adrc[].
        SORT lt_cust BY sort2.
        READ TABLE lt_cust WITH KEY sort2 = '' BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE t_t001 WITH KEY adrnr = lt_cust-addrnumber.
          MESSAGE i000(zab) WITH 'Please maintain customer number'
                                 'for company'
                                 t_t001-bukrs.
          STOP.
        ENDIF.
      ENDIF.
    ENDIF.

**--Get Config data
    SELECT * INTO TABLE t_fidt0001
             FROM zgdfidt0001
             WHERE ekgrp IN s_ekgrp AND
                   bsart IN s_bsart.
    SORT t_fidt0001 BY ekgrp bsart.

**--Get PO data
*    SELECT ebeln lifnr knumv waers
*           INTO CORRESPONDING FIELDS OF TABLE t_ekko
*           FROM ekko
*           WHERE ebeln IN s_ebeln.

    SELECT ebeln lifnr knumv waers
           INTO CORRESPONDING FIELDS OF TABLE t_ekko
           FROM ekko
           FOR ALL ENTRIES IN t_s911kor
           WHERE ebeln EQ t_s911kor-ebeln.

    IF sy-subrc = 0.
      SORT t_ekko BY ebeln.
      SELECT lifnr name1
             INTO CORRESPONDING FIELDS OF TABLE t_lfa1
             FROM lfa1
             FOR ALL ENTRIES IN t_ekko
             WHERE lifnr = t_ekko-lifnr.
      SORT t_lfa1 BY lifnr.

      SELECT ebeln ebelp loekz  netwr
             INTO CORRESPONDING FIELDS OF TABLE t_ekpo1
             FROM ekpo
             FOR ALL ENTRIES IN t_ekko
             WHERE ebeln = t_ekko-ebeln.

*      delete t_ekpo1 where loekz = 'L'.
*      delete ADJACENT DUPLICATES FROM t_ekpo1 COMPARING ebeln.
      sw = 0.
      CLEAR: l_ebelp.
      IF t_ekpo1[] IS NOT INITIAL.
        SORT t_ekpo1 BY ebeln ebelp loekz.
        SORT t_ekko BY ebeln.
        SORT t_ekpo1 BY ebeln ebelp loekz.
        LOOP AT t_ekko.
          sw = 2.
          LOOP AT t_ekpo1 WHERE ebeln = t_ekko-ebeln.
            IF t_ekpo1-loekz NE 'L'.
              IF t_ekpo1-netwr NE 0.
                t_ekko-ebelp = t_ekpo1-ebelp.
                sw = 0.
                EXIT.
              ENDIF.
            ELSE.
              IF t_ekpo1-netwr NE 0.
                l_ebelp = t_ekpo1-ebelp.
                sw = 1.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF sw = 1.
            t_ekko-ebelp =  l_ebelp.
          ENDIF.
*          READ TABLE t_ekpo1 WITH KEY ebeln = t_ekko-ebeln BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            t_ekko-ebelp = t_ekpo1-ebelp.
*          ENDIF.
          MODIFY t_ekko.
        ENDLOOP.
      ENDIF.

**----Get more data from PO table for foreign currency
      IF NOT t_s911kor[] IS INITIAL.
        t_ekkof[] = t_ekko[].
        DELETE t_ekkof WHERE waers = 'IDR'.
*_______Added By SAP_DEV06 Yudhois 9-04-2007.
        IF  NOT t_ekkof[] IS INITIAL.
*_______End of Added By SAP_DEV06 Yudhois 9-04-2007.
          SORT t_ekkof BY knumv ebelp.
          SELECT knumv kposn kbetr kwert
                 INTO CORRESPONDING FIELDS OF TABLE t_konv
                 FROM konv
                 FOR ALL ENTRIES IN t_ekkof
                 WHERE knumv = t_ekkof-knumv AND
                       kposn = t_ekkof-ebelp AND
                       kappl = 'M' AND
                       kschl = 'ZFEE'.
*_______Added By SAP_DEV06 Yudhois 9-04-2007.
        ENDIF.
*_______End of Added By SAP_DEV06 Yudhois 9-04-2007.
        SORT t_konv BY knumv.
****************** Tanbah disini untuk delete item yg sudah didelete
        IF t_ekpo1[] IS NOT INITIAL.
          LOOP AT t_ekpo1.
            DELETE t_konv WHERE knumv = t_ekpo1-knumv AND kposn = t_ekpo1-ebelp.
          ENDLOOP.
        ENDIF.
******************************************************

      ENDIF.
    ENDIF.

***-For printing FP - Rahmadi 03/04/2005
    IF NOT p_fp IS INITIAL OR
      p_faktu IS NOT INITIAL.
      SELECT SINGLE a~fakdat
                    b~fakturno b~vbeln b~gjahr b~ppnlast b~form
                                   INTO CORRESPONDING FIELDS OF wa_fp
                                   FROM zgdtxdt0003 AS a JOIN
                                        zgdtxdt0002 AS b
                                   ON a~bukrs = b~bukrs AND
                                      a~brnch = b~brnch AND
                                      a~busln = b~busln AND
                                      a~fakturno = b~fakturno AND
                                      a~vbeln    = b~vbeln
                                   WHERE a~bukrs = d_tnt_bukrs AND
                                         a~batal = '' AND
                                         b~vbeln = p_belnr AND
                                         b~gjahr = p_stjah.
      IF sy-subrc <> 0.
        MESSAGE i000(zab) WITH 'Faktur pajak has not been processed'.
        PERFORM f_free_memory.
        STOP.
      ELSE.
        IF wa_fp-fakturno CP 'BATAL' OR
           wa_fp-ppnlast = 0.
          MESSAGE i000(zab) WITH 'Faktur pajak has been cancelled'.
          PERFORM f_free_memory.
          STOP.
        ENDIF.
      ENDIF.
    ENDIF.

**--Copy original data
    t_s911kor_orig[] = t_s911kor[].

**--Forming screen table
    SORT t_s911kor BY bukrs ekgrp bsart ebeln.
    CLEAR ld_no.
    LOOP AT t_s911kor.

*-----Get only PO for selected Plants for Billing Create & Report
      ld_ekpo = 'X'.
      IF NOT p_rep IS INITIAL OR
         NOT p_crb IS INITIAL.
        IF t_s911kor-ebeln CS 'X'.
          ld_ekpo = 'X'.
*          IF NOT p_crb IS INITIAL AND
*             NOT s_werks-low IS INITIAL.
*            CLEAR ld_ekpo.
*          ENDIF.
        ELSE.
          READ TABLE t_ekpo WITH KEY ebeln = t_s911kor-ebeln BINARY SEARCH.
          IF sy-subrc = 0.
            ld_ekpo = 'X'.
          ELSE.
            CLEAR ld_ekpo.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ld_ekpo = 'X'.
*-------Lock object
        CLEAR: t_9010, t_t001, t_adrc, t_ekko, t_lfa1, t_fidt0001,
               t_konv.
        IF ld_uname IS INITIAL.   "not locked
          ld_no = ld_no + 1.
          MOVE-CORRESPONDING t_s911kor TO t_9010.

***--Customer
          READ TABLE t_t001 WITH KEY bukrs = t_s911kor-bukrs BINARY SEARCH.
          IF p_crb = 'X'.
            IF ld_cust_flag IS INITIAL.
              READ TABLE t_adrc WITH KEY addrnumber = t_t001-adrnr
                                BINARY SEARCH.
              t_9010-kunnr = t_adrc-sort2.
            ELSE.
              t_9010-kunnr = d_kunnr.
            ENDIF.
            t_9010-namec = t_t001-butxt.
          ELSE.
            READ TABLE t_bseg WITH KEY belnr = t_s911kor-belnr
                                       gjahr = t_s911kor-stjah
                                       BINARY SEARCH.
            IF sy-subrc = 0.
              t_9010-kunnr = t_bseg-kunnr.
            ELSE.
              READ TABLE t_adrc WITH KEY addrnumber = t_t001-adrnr
                                BINARY SEARCH.
              t_9010-kunnr = t_adrc-sort2.
              t_9010-namec = t_t001-butxt.
            ENDIF.
          ENDIF.

****--Vendor
          IF ld_ekpo = 'X' AND              "only if exist in EKKO~EKPO
             NOT t_s911kor-ebeln CS 'X'.
            READ TABLE t_ekko WITH KEY ebeln = t_s911kor-ebeln
                       BINARY SEARCH.
            READ TABLE t_lfa1 WITH KEY lifnr = t_ekko-lifnr
                       BINARY SEARCH.
            t_9010-lifnr = t_lfa1-lifnr.
            t_9010-name1 = t_lfa1-name1.

****--Value if PO is in foreign currency
            CLEAR t_konv-kbetr.
            IF t_ekko-waers <> 'IDR'.
              READ TABLE t_konv WITH KEY knumv = t_ekko-knumv
                                BINARY SEARCH.
***** Koreksi pengambilan Fee Koreksi 28/09/2005
              IF t_9010-vrsio EQ '000' AND
                t_9010-netwr NE 0.
***** End Koreksi
                IF t_9010-kzwi1 < 0.
                  t_9010-kzwi1 = ( -1 ) * t_konv-kbetr.
                ELSE.
                  t_9010-kzwi1 = t_konv-kbetr.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

****--Get data based on EKGRP & BSART
          READ TABLE t_fidt0001 WITH KEY ekgrp = t_s911kor-ekgrp
                                         bsart = t_s911kor-bsart
                                         BINARY SEARCH.

*-----Keep Customer company code for Saving purpose
          t_9010-bukrs_d = t_s911kor-bukrs.

          MOVE-CORRESPONDING t_fidt0001 TO t_9010.
          CONCATENATE t_s911kor-ekgrp t_s911kor-bsart INTO t_9010-ekgart.

****--Status
          IF t_s911kor-vrsio = d_vrsio_orig.
            t_9010-sts = d_new.
          ELSE.
            t_9010-sts = d_cor.
          ENDIF.

****--line number
          t_9010-no = ld_no.

**** Add by budi 30/11/2005
          READ TABLE t_bkpf WITH KEY belnr = t_9010-belnr.
          IF sy-subrc = 0.
            t_9010-xblnr = t_bkpf-xblnr.
          ENDIF.
**** EndAdd

***** Jika amount = 0 dan fee ada isinya maka data tidak tampil dan modify table S911nya
          IF t_9010-netwr EQ 0.
*-------Update database table
            t_s911kor-kzwi1 = 0.
            ld_no = ld_no - 1.
            MODIFY TABLE t_s911kor TRANSPORTING kzwi1.
            UPDATE zs911kor FROM t_s911kor.
            COMMIT WORK.
          ELSE.
            APPEND t_9010.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

    ENDLOOP.

*  SORT t_9010 BY kunnr ekgrp bsart.

****Get Further Customer data
    lt_kunnr[] = t_9010[].
    SORT lt_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.
    IF NOT lt_kunnr[] IS INITIAL.
      SELECT a~kunnr a~name1 a~stras a~ort01 a~pstlz a~stceg a~stkzu
             a~adrnr a~stcd1
             b~bukrs b~zterm
             INTO CORRESPONDING FIELDS OF TABLE t_kna1
             FROM kna1 AS a JOIN knb1 AS b
             ON a~kunnr = b~kunnr
             FOR ALL ENTRIES IN lt_kunnr
             WHERE a~kunnr = lt_kunnr-kunnr AND
                   b~bukrs = d_tnt_bukrs.
      IF sy-subrc = 0.
        SELECT addrnumber street name_co str_suppl1 str_suppl2
               str_suppl3 location post_code1
               INTO TABLE t_adrcz
               FROM adrc
               FOR ALL ENTRIES IN t_kna1
               WHERE addrnumber = t_kna1-adrnr.
        SORT t_adrcz BY addrnumber.

        SORT t_kna1 BY kunnr.
        lt_kna1x[] = t_kna1[].
        SORT lt_kna1x BY zterm.
        DELETE ADJACENT DUPLICATES FROM lt_kna1x COMPARING zterm.
        SELECT zterm ztag1
               INTO TABLE t_t052
               FROM t052
               FOR ALL ENTRIES IN lt_kna1x
               WHERE zterm = lt_kna1x-zterm.
        SORT t_t052 BY zterm.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_proses_report_kor

*&---------------------------------------------------------------------*
*&      Form  F_GET_WAPU
*&---------------------------------------------------------------------*
*&  This routine collects WAPU data for the selected billings
*&---------------------------------------------------------------------*
*&  ->FU_KUNRG   - Customer number
*&  <-FC_WAPU    - WAPU
*&  <-FC_FORM    - Used Tax form
*&---------------------------------------------------------------------*
FORM f_get_wapu USING    fu_kunrg
                CHANGING fc_wapu
                         fc_form.

  READ TABLE t_kna1 WITH KEY kunnr = fu_kunrg
                    BINARY SEARCH.
  IF sy-subrc = 0.
    IF t_kna1-stcd1+0(1) = d_w.
      fc_wapu = d_w.
      fc_form = d_a3.
    ELSE.
      fc_wapu = d_n.
      fc_form = d_a1.
    ENDIF.
  ELSE.
    CLEAR fc_wapu.
  ENDIF.
ENDFORM.                    " F_GET_WAPU
*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
*&    This routine assigns new sequence number to a new faktur pajak.
*&    The assignment is specific for each PKP, therefore the object
*&    range and business area passed to this routine are retrieved from
*&    F_GET_PKP routine as a preceeding process that has to be performed
*&    BEFORE performing this routine.
*&---------------------------------------------------------------------*
*&    ->FU_OBJECT   -  Number range Object id
*&    ->FU_GSBER    -  Business area as a sub-object of the number range
*&    <-FC_FAKTURNO -  New faktur no.
*&    <-FC_SUBRC    -  This parameter will be <> 0 if no new number can
*&                     be assigned to the faktur pajak
*&---------------------------------------------------------------------*
FORM f_get_next_number USING fu_object
                             fu_gsber
                             fu_brnch
                             fu_masatx
                             fu_form
                             fu_asset
                             fu_fakdat
                    CHANGING fc_fakturno fc_subrc.

  DATA lw_nriv     LIKE nriv.
  DATA ld_nrlevel  LIKE nriv-tonumber.
  DATA ld_fakturno LIKE nriv-nrlevel.
  DATA ld_fakno    LIKE nriv-nrlevel.
  DATA ld_vatno    LIKE zfvatnr-vatno.
  DATA ld_posnr    LIKE zfvatnr-posnr.
  DATA lc_vatno(8).
  DATA ld_vatbr(3).
  DATA ld_vattrn   LIKE zfvattrn-vattrn.
  DATA ld_vatno1(10).
  DATA: lv_datum LIKE sy-datum.
  DATA: lv_date LIKE sy-datum.
  DATA: lt_fakturno    TYPE STANDARD TABLE OF zgdtxdt0011
                        WITH HEADER LINE,
        lt_zfvatnr     TYPE STANDARD TABLE OF zfvatnr
                        WITH HEADER LINE,
        lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl
                        WITH HEADER LINE,
        ld_reuse,

        ld_masatx      LIKE zgdtxdt0011-masatx.
  DATA: l_len    TYPE i, l_posisi TYPE i.

  RANGES: lr_masatx FOR zgdtxdt0011-masatx.

  CLEAR: ld_masatx, lr_masatx.
  REFRESH lr_masatx.
  ld_masatx = fu_masatx - 1.
  lr_masatx-sign   = 'I'.
  lr_masatx-option = 'EQ'.
  lr_masatx-low    = ld_masatx.
  APPEND lr_masatx.
  lr_masatx-low    = fu_masatx.
  APPEND lr_masatx.

  CLEAR: fc_subrc, ld_posnr.
  fc_subrc = 3.
  ld_posnr = 10.
*  IF fu_masatx(4) GT 2006.

  SELECT SINGLE vattrn vatbr
    FROM zfvattrn
    INTO (ld_vattrn, ld_vatbr)
    WHERE vkorg EQ fu_brnch AND
          gform EQ fu_form.

  IF fu_asset EQ 'X'.
    ld_vattrn = '09'.
  ENDIF.

  IF fu_fakdat > gs_dpp-datab.
    IF ld_vattrn = '01'.
      ld_vattrn = '04'.
    ENDIF.
  ENDIF.

* check reuseable faktur number
  SELECT *
    FROM zgdtxdt0011
    INTO TABLE lt_fakturno
    WHERE brnch    EQ fu_brnch  AND
          masatx   IN lr_masatx AND
          objrange EQ fu_object.
  IF sy-subrc EQ 0.
    SORT lt_fakturno BY fakturno masatx.
    CLEAR ld_reuse.
    CLEAR: sy-subrc.
    LOOP AT lt_fakturno.
      CALL FUNCTION 'ENQUEUE_EZGDTXDT0011'
        EXPORTING
          mode_zgdtxdt0011 = 'E'
          mandt            = sy-mandt
*         gsber            = fu_gsber
          brnch            = fu_brnch
          fakturno         = lt_fakturno-fakturno
          masatx           = lt_fakturno-masatx
          objrange         = lt_fakturno-objrange
        EXCEPTIONS
          foreign_lock     = 1
          system_failure   = 2
          OTHERS           = 3.
      IF sy-subrc = 0.
        CLEAR ld_reuse.
        MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
        APPEND t_zgdtxdt0011.
        EXIT.
      ELSE.
        ld_reuse = 'X'.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    ld_vatno1 = lt_fakturno-fakturno+6(10).
    CONCATENATE ld_vattrn '0' ld_vatbr ld_vatno1
    INTO fc_fakturno.
    DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
  ELSE.
*--- Tambahan kondisi penomoran faktur pajak mulai dari tahun 2013
    CONCATENATE fu_masatx '01' INTO lv_datum.
    SELECT SINGLE datab  INTO lv_date FROM zproject WHERE name = 'PAJAK2013' AND datab > lv_datum.
    IF sy-subrc EQ 0.
      SELECT SINGLE vatno
        FROM zfvatnr
        INTO ld_vatno
        WHERE vkorg EQ fu_brnch AND
              vkbur EQ ld_vatbr AND
              gjahr EQ fu_masatx(4).

      ld_vatno = ld_vatno + 1.
      UPDATE zfvatnr SET vatno = ld_vatno
                     WHERE vkorg EQ fu_brnch AND
                           vkbur EQ ld_vatbr AND
                           gjahr EQ fu_masatx(4).
      CONCATENATE ld_vattrn '0' ld_vatbr fu_masatx+2(2) ld_vatno
      INTO fc_fakturno.
      CLEAR fc_subrc.
    ELSE.
      SELECT SINGLE *
        FROM zfvatnr
        INTO lt_zfvatnr
        WHERE vkorg EQ fu_brnch AND
              vkbur EQ ld_vatbr AND
              gjahr EQ fu_masatx(4).
      IF lt_zfvatnr-posnr EQ 0.
        SELECT SINGLE *
          FROM zfvatnr_dtl
          INTO lt_zfvatnr_dtl
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ ld_vatbr AND
                gjahr EQ fu_masatx(4) AND
                posnr EQ ld_posnr.
        IF sy-subrc EQ 0.
          CONDENSE lt_zfvatnr_dtl-vatpr.
          l_len = strlen( lt_zfvatnr_dtl-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            UPDATE zfvatnr SET vatno = lt_zfvatnr_dtl-vatfr
                               vatfr = lt_zfvatnr_dtl-vatfr
                               vatto = lt_zfvatnr_dtl-vatto
                               vatcd = lt_zfvatnr_dtl-vatcd
                               vatpr = lt_zfvatnr_dtl-vatpr
                               posnr = lt_zfvatnr_dtl-posnr
                               vatdt = sy-datum
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ ld_vatbr AND
                gjahr EQ fu_masatx(4).
            IF sy-subrc EQ 0.
              lc_vatno = lt_zfvatnr_dtl-vatfr.
              l_posisi = l_len.
              l_len = 8 - l_len.
              lc_vatno = lc_vatno+l_posisi(l_len).
              CONCATENATE ld_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lc_vatno
              INTO fc_fakturno.
              CLEAR fc_subrc.
            ENDIF.
          ENDIF.
        ELSE.
          fc_subrc = 3.
        ENDIF.
      ELSE.
        ld_vatno = lt_zfvatnr-vatno + 1.
        IF ld_vatno <= lt_zfvatnr-vatto.
          CONDENSE lt_zfvatnr-vatpr.
          l_len = strlen( lt_zfvatnr-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            UPDATE zfvatnr SET vatno = ld_vatno
                           WHERE vkorg EQ fu_brnch AND
                                 vkbur EQ ld_vatbr AND
                                 gjahr EQ fu_masatx(4).
            l_posisi = l_len.
            l_len = 8 - l_len.
            lc_vatno = ld_vatno+l_posisi(l_len).

            CONCATENATE ld_vattrn '0' lt_zfvatnr-vatcd fu_masatx+2(2) lt_zfvatnr-vatpr lc_vatno
            INTO fc_fakturno.
            CLEAR fc_subrc.
          ENDIF.
        ELSE.
          lt_zfvatnr-posnr = lt_zfvatnr-posnr + 10.
          SELECT SINGLE *
            FROM zfvatnr_dtl
            INTO lt_zfvatnr_dtl
            WHERE vkorg EQ fu_brnch AND
                  vkbur EQ ld_vatbr AND
                  gjahr EQ fu_masatx(4) AND
                  posnr EQ lt_zfvatnr-posnr.
          IF sy-subrc EQ 0.
            UPDATE zfvatnr SET vatno = lt_zfvatnr_dtl-vatfr
                               vatfr = lt_zfvatnr_dtl-vatfr
                               vatto = lt_zfvatnr_dtl-vatto
                               vatcd = lt_zfvatnr_dtl-vatcd
                               vatpr = lt_zfvatnr_dtl-vatpr
                               posnr = lt_zfvatnr_dtl-posnr
                               vatdt = sy-datum
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ ld_vatbr AND
                gjahr EQ fu_masatx(4).
            IF sy-subrc EQ 0.
              CONCATENATE ld_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lt_zfvatnr_dtl-vatfr
              INTO fc_fakturno.
              CLEAR fc_subrc.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.


*  DATA lw_nriv     LIKE nriv.
*  DATA ld_nrlevel  LIKE nriv-tonumber.
*  DATA ld_fakturno LIKE nriv-nrlevel.
*  DATA ld_fakno    LIKE nriv-nrlevel.
*  DATA ld_vatno    LIKE zfvatnr-vatno.
*  DATA ld_vatbr(3).
*  DATA ld_vattrn   LIKE zfvattrn-vattrn.
*  DATA ld_vatno1(10).
*
*  DATA  d_fpone      LIKE zgdtxdt0005-fpone.
*  DATA  d_fptwo      LIKE zgdtxdt0005-fptwo.
*
*  DATA: lt_fakturno TYPE STANDARD TABLE OF zgdtxdt0011
*                        WITH HEADER LINE,
*        ld_reuse,
*        ld_masatx LIKE zgdtxdt0011-masatx.
*
*  RANGES: lr_masatx FOR zgdtxdt0011-masatx.
*
*  CLEAR: ld_masatx, lr_masatx.
*  REFRESH lr_masatx.
*
*  ld_masatx = fu_masatx - 1.
*  lr_masatx-sign   = 'I'.
*  lr_masatx-option = 'EQ'.
*  lr_masatx-low    = ld_masatx.
*  APPEND lr_masatx.
*  lr_masatx-low    = fu_masatx.
*  APPEND lr_masatx.
*
*  CLEAR fc_subrc.
*
**--- Tambahan kondisi penomoran faktur pajak mulai dari tahun 2007
*  IF fu_masatx(4) GT 2006.
*
*    SELECT SINGLE vattrn vatbr
*      FROM zfvattrn
*      INTO (ld_vattrn, ld_vatbr)
*      WHERE vkorg EQ fu_brnch AND
*            gform EQ fu_form.
*
*    IF fu_asset EQ 'X'.
*      ld_vattrn = '09'.
*    ENDIF.
*
** check reuseable faktur number
*    SELECT *
*      FROM zgdtxdt0011
*      INTO TABLE lt_fakturno
*      WHERE brnch    EQ fu_brnch  AND
*            masatx   IN lr_masatx AND
*            objrange EQ fu_object.
*    IF sy-subrc EQ 0.
*      SORT lt_fakturno BY fakturno masatx.
*      CLEAR ld_reuse.
*      CLEAR: sy-subrc.
*      LOOP AT lt_fakturno.
*        CALL FUNCTION 'ENQUEUE_EZGDTXDT0011'
*             EXPORTING
*                  mode_zgdtxdt0011 = 'E'
*                  mandt              = sy-mandt
**                gsber              = fu_gsber
*                  brnch              = fu_brnch
*                  fakturno           = lt_fakturno-fakturno
*                  masatx             = lt_fakturno-masatx
*                  objrange           = lt_fakturno-objrange
*             EXCEPTIONS
*                  foreign_lock       = 1
*                  system_failure     = 2
*                  OTHERS             = 3.
*        IF sy-subrc = 0.
*          CLEAR ld_reuse.
*          MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
*          APPEND t_zgdtxdt0011.
*          EXIT.
*        ELSE.
*          ld_reuse = 'X'.
*          CONTINUE.
*        ENDIF.
*      ENDLOOP.
*
*      ld_vatno1 = lt_fakturno-fakturno+6(10).
*      CONCATENATE ld_vattrn '0' ld_vatbr ld_vatno1
*      INTO fc_fakturno.
*      DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
*    ELSE.
*      SELECT SINGLE vatno
*        FROM zfvatnr
*        INTO ld_vatno
*        WHERE vkorg EQ fu_brnch AND
*              vkbur EQ ld_vatbr AND
*              gjahr EQ fu_masatx(4).
*
*      ld_vatno = ld_vatno + 1.
*      UPDATE zfvatnr SET vatno = ld_vatno
*                     WHERE vkorg EQ fu_brnch AND
*                           vkbur EQ ld_vatbr AND
*                           gjahr EQ fu_masatx(4).
*      CONCATENATE ld_vattrn '0' ld_vatbr fu_masatx+2(2) ld_vatno
*      INTO fc_fakturno.
*    ENDIF.
*  ELSE.
**---
*
***Get record with current number <> 0
*    SELECT SINGLE * INTO lw_nriv FROM nriv
*           WHERE object = fu_object AND
**               subobject = fu_gsber AND
*                 subobject = fu_brnch AND
*                   nrlevel <> '0'.
*    IF sy-subrc = 0.
*****Current no must be <> Last no
*      MOVE lw_nriv-nrlevel TO ld_nrlevel.
*
*      PERFORM f_delete_leading_zero
*              CHANGING ld_nrlevel.
*
*****added by Rahmadi
*      PERFORM f_delete_leading_zero
*              CHANGING lw_nriv-tonumber.
*****end of addition
*      IF ld_nrlevel = lw_nriv-tonumber.
*****Modified by Rahmadi
*        SELECT SINGLE * INTO lw_nriv FROM nriv
*               WHERE object = fu_object AND
**              subobject = fu_gsber AND
*                  subobject = fu_brnch AND
*                    nrlevel = '0'.
*        IF sy-subrc <> 0.
*          CLEAR fc_fakturno.
*          fc_subrc = 3.
*          EXIT.
*        ENDIF.
**      CLEAR fc_fakturno.
**      fc_subrc = 2.
**      EXIT.
*****end of modification
*      ENDIF.
*    ELSE.
*****Not found, get NEW nrange id (curr no = '0')
*      SELECT SINGLE * INTO lw_nriv FROM nriv
*             WHERE object = fu_object AND
**              subobject = fu_gsber AND
*                subobject = fu_brnch AND
*                  nrlevel = '0'.
*      IF sy-subrc <> 0.
*        CLEAR fc_fakturno.
*        fc_subrc = 3.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
***Get next number in the range
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        nr_range_nr             = lw_nriv-nrrangenr
*        object                  = fu_object
*        subobject               = lw_nriv-subobject
*      IMPORTING
*        number                  = ld_fakno
*      EXCEPTIONS
*        interval_not_found      = 1
*        number_range_not_intern = 2
*        object_not_found        = 3
*        interval_overflow       = 6
*        OTHERS                  = 7.
*    IF sy-subrc <> 0.
*      CLEAR fc_fakturno.
*      fc_subrc = 3.
*      EXIT.
*    ENDIF.
*
**  macro_faktur_formatting ld_fakno ld_fakturno.
*
*    IF NOT d_fpone IS INITIAL AND NOT d_fptwo IS INITIAL.
*      CONCATENATE d_fpone '-' d_fptwo '-'
*                  ld_fakno+13(7)
*                  INTO fc_fakturno.
*    ELSE.
*      MOVE ld_fakno+13(7) TO fc_fakturno.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_LEADING_ZERO
*&---------------------------------------------------------------------*
*& This routine is delete leading zero of tax number range.
*& I don't simply just move it into packed number, and return it again
*& to character, because tax number range has 20 digits, even though
*& it only has 7 digits, but i prefer the save way...
*& (Note Packed Number has maximum 16 digits)
*&---------------------------------------------------------------------*
FORM f_delete_leading_zero
     CHANGING fc_number.
  DATA:
    ld_length  TYPE i,
    ld_counter TYPE i.
  ld_length = strlen( fc_number ).
  ld_counter = 0.
  WHILE ld_counter < ld_length AND fc_number+ld_counter(1) = '0'.
    ld_counter = ld_counter + 1.
  ENDWHILE.

  ld_length = ld_length - ld_counter.
  fc_number = fc_number+ld_counter(ld_length).

ENDFORM.                    "f_delete_leading_zero

*&---------------------------------------------------------------------*
*&      Form  f_process_non_trade
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_TNT_BUKRS  text
*      -->P_T_CRB_HEAD_BELNR  text
*      -->P_BKPF_BUDAT+4(2)  text
*      -->P_BKPF_BUDAT(4)  text
*      <--P_VA_FAKNO  text
*----------------------------------------------------------------------*
FORM f_process_non_trade  USING    fu_bukrs
                                   fu_belnr
                                   fu_monat
                                   fu_gjahr
                          CHANGING fc_fakno.
  DATA: ld_masatx LIKE zgdtxdt0003-masatx.

  REFRESH: t_bdcdata.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'ZGDTX_E0029'               '1000',
   ' '  'BDC_OKCODE'                '=ONLI',
   ' '  'P_BUKRS'                   fu_bukrs,
   ' '  'P_BRNCH'                   fu_bukrs,
   ' '  'P_EXCLD'                   'X',
   ' '  'S_BELNR-LOW'               fu_belnr,
   ' '  'P_MONAT'                   fu_monat,
   ' '  'P_GJAHR'                   fu_gjahr.
  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'SAPMSSY0'                  '0120',
   ' '  'BDC_OKCODE'                '=PROC'.
  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'SAPMSSY0'                  '0120',
   ' '  'BDC_OKCODE'                '=&F15'.
  PERFORM f_bdc_data TABLES t_bdcdata USING:
   'X'  'ZGDTX_E0029'               '1000',
   ' '  'BDC_OKCODE'                '/EE'.

  d_bdc_batch = 'E'.
  PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                          t_bdcmsg
                                   USING 'ZGDTXE0029' d_bdc_tctxt.
  IF d_bdc_error = 0.
    CONCATENATE fu_gjahr fu_monat INTO ld_masatx.

    SELECT SINGLE fakturno
      FROM zgdtxdt0003
      INTO fc_fakno
      WHERE bukrs EQ fu_bukrs   AND
            brnch EQ fu_bukrs   AND
            masatx EQ ld_masatx AND
            vbeln  EQ fu_belnr.
  ENDIF.
  REFRESH: t_bdcdata.
ENDFORM.                    " f_process_non_trade

*&---------------------------------------------------------------------*
*&      Form  f_selected_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_selected_period .
  DATA: ld_closedat LIKE zgdtxdt0004-closedat,
        ld_masatx   LIKE zgdtxdt0004-masatx.

  CLEAR: ld_closedat, ld_masatx.
  ld_masatx = bkpf-budat(6).
  SELECT SINGLE masatx closedat FROM zgdtxdt0004
                       INTO (ld_masatx, ld_closedat)
                       WHERE bukrs    = d_tnt_bukrs AND
                             brnch    = d_tnt_bukrs AND
                             masatx   = ld_masatx.

  IF sy-subrc NE 0.
    CONCATENATE t_status-msg '( Masa pajak belum dibuka )' INTO t_status-msg
    SEPARATED BY space.
  ENDIF.

  IF NOT ld_closedat IS INITIAL.
    CONCATENATE t_status-msg '( Masa Pajak sudah ditutup )' INTO t_status-msg
    SEPARATED BY space.
  ENDIF.
  MODIFY t_status INDEX 1 TRANSPORTING msg.
ENDFORM.                    " F_SELECT_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_ZGDFIDT0005
*&---------------------------------------------------------------------*
FORM f_zgdfidt0005  USING    fu_flag
                             fu_s911 STRUCTURE s911.

  CASE fu_flag.
    WHEN 'U'.
      UPDATE zgdfidt0005 SET zdesc1 = zgdfidt0005-zdesc1
                         WHERE spmon  EQ fu_s911-spmon AND
                               bukrs  EQ fu_s911-bukrs AND
                               ekgrp  EQ fu_s911-ekgrp AND
                               bsart  EQ fu_s911-bsart AND
                               bedat  EQ fu_s911-bedat AND
                               ebeln  EQ fu_s911-ebeln AND
                               vrsio  EQ fu_s911-vrsio.
    WHEN 'I'.
      zgdfidt0005-spmon  = s911-spmon.
      zgdfidt0005-bukrs  = s911-bukrs.
      zgdfidt0005-ekgrp  = s911-ekgrp.
      zgdfidt0005-bsart  = s911-bsart.
      zgdfidt0005-bedat  = s911-bedat.
      zgdfidt0005-ebeln  = s911-ebeln.
      zgdfidt0005-vrsio  = s911-vrsio.
      INSERT zgdfidt0005.
  ENDCASE.

ENDFORM.                    " F_ZGDFIDT0005

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VAT_DATE
*&---------------------------------------------------------------------*
FORM f_check_vat_date  .

  DATA : ld_vatbr(3),
         ld_vattrn   LIKE zfvattrn-vattrn,
         lr_datum    TYPE RANGE OF datum,
         wa_dudat    LIKE LINE OF lr_datum.

  DATA : lt_zfvatnr     TYPE STANDARD TABLE OF zfvatnr
                    WITH HEADER LINE,
         lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl
                        WITH HEADER LINE.

  READ TABLE t_crb_head INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE vattrn vatbr
      FROM zfvattrn
      INTO (ld_vattrn, ld_vatbr)
      WHERE vkorg = t_crb_head-bukrs
        AND gform = 'A1'.

    SELECT SINGLE *
      FROM zfvatnr
      INTO lt_zfvatnr
      WHERE vkorg = t_crb_head-bukrs
        AND vkbur = ld_vatbr
        AND gjahr = t_crb_head-budat(4).

    SELECT SINGLE *
      FROM zfvatnr_dtl
      INTO lt_zfvatnr_dtl
      WHERE vkorg = t_crb_head-bukrs
        AND vkbur = ld_vatbr
        AND gjahr = t_crb_head-budat(4)
        AND posnr = lt_zfvatnr-posnr.

    IF lt_zfvatnr_dtl-validfr IS NOT INITIAL AND
      lt_zfvatnr_dtl-validto IS NOT INITIAL.
      wa_dudat-low      = lt_zfvatnr_dtl-validfr.
      wa_dudat-high     = lt_zfvatnr_dtl-validto.
      wa_dudat-sign     = 'I'.
      wa_dudat-option   = 'BT'.
      APPEND wa_dudat TO lr_datum.
    ENDIF.

    IF t_crb_head-budat IN lr_datum.
    ELSE.
      MESSAGE 'Tanggal faktur tidak ada di ranges tanggal' TYPE 'E'.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_VAT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_NEW_FAKTUR_TNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_move_to_new_faktur_tnt  TABLES   ft_item STRUCTURE zgdfist0002
                               USING    fw_head LIKE t_crb_head.
  DATA: lv_dudat TYPE dats,
        lv_budat LIKE gv_header-budat.

  DATA: lv_total   TYPE zgdfist0001-total.

  IF gt_monthnames[] IS INITIAL.
    CALL FUNCTION 'MONTH_NAMES_GET'
      EXPORTING
        language    = 'i'
      TABLES
        month_names = gt_monthnames.
  ENDIF.

  SORT t_kna1 BY kunnr.
  SORT t_adrcz BY addrnumber.

  CLEAR: gv_header,gt_detail,gt_detail[],lv_dudat,t_kna1,t_adrcz,gt_monthnames.

  READ TABLE t_kna1 WITH KEY kunnr = fw_head-kunnr BINARY SEARCH.
  READ TABLE t_adrcz WITH KEY addrnumber = t_kna1-adrnr BINARY SEARCH.

  gv_header-title     = 'FAKTUR'.
  WRITE fw_head-belnr TO gv_header-vbeln NO-ZERO.
  gv_header-xblnr     = fw_head-xblnr.
  gv_header-kunrg     = gv_header-kunag = fw_head-kunnr.

  IF bseg-kidno IS INITIAL.
    READ TABLE ft_item INDEX 1.
    IF sy-subrc = 0.
      bseg-kidno = ft_item-kidno.
    ENDIF.
  ENDIF.

  PERFORM f_modifikasi_alamat USING bseg-kidno
                              CHANGING t_adrcz-name_co t_adrcz-str_suppl1
                                       t_adrcz-str_suppl2 t_adrcz-str_suppl3
                                       t_adrcz-location.

  gv_header-name1_rg  = gv_header-name1_ag = t_adrcz-name_co.
  gv_header-addr1_rg  = gv_header-addr1_ag = t_adrcz-str_suppl1.
  gv_header-addr2_rg  = gv_header-addr2_ag = t_adrcz-str_suppl2.
  gv_header-addr3_rg  = gv_header-addr3_ag = t_adrcz-str_suppl3.
  gv_header-addr4_rg  = gv_header-addr4_ag = t_adrcz-location.
  gv_header-stceg_rg  = gv_header-stceg_ag = t_kna1-stceg.
*  gv_header-harga_jual = gv_header-dpp = fw_head-numtot.
*  gv_header-nilai_fak = fw_head-grossnum.

*  IF lv_budat > gs_dpp-datab.
  IF fw_head-budat > gs_dpp-datab.
    lv_total  = fw_head-total * 11 / 12.
    WRITE: lv_total TO gv_header-dpp CURRENCY fw_head-hwaer.
  ELSE.
    WRITE: fw_head-total TO gv_header-dpp CURRENCY fw_head-hwaer.
  ENDIF.

  WRITE: fw_head-total TO gv_header-harga_jual CURRENCY fw_head-hwaer,
         fw_head-grossamt TO gv_header-nilai_fak CURRENCY fw_head-hwaer.
  gv_header-nameadm   = fw_head-nameadm.
  gv_header-jabatadm  = fw_head-jabatadm.
  gv_header-bstkd     = '-'.
  gv_header-bstdk     = '-'.
  gv_header-spno      = '-'.
  gv_header-fkdat     = '-'.

  gv_header-ppncd     = fw_head-ppncd.

  lv_dudat = fw_head-zfbdt + fw_head-ztag1.

  WRITE lv_dudat TO gv_header-dudat.
  WRITE fw_head-budat TO lv_budat.
  WRITE fw_head-ztag1 TO gv_header-ztag1 NO-ZERO. CONDENSE gv_header-ztag1.
  WRITE fw_head-amount_ppn TO gv_header-ppn CURRENCY 'IDR'.

  READ TABLE gt_monthnames WITH KEY mnr = lv_budat+3(2).
  CONCATENATE lv_budat(2) gt_monthnames-ltx lv_budat+6(4) INTO gv_header-budat
    SEPARATED BY space.

  PERFORM f_get_fakno USING fw_head-belnr fw_head-bukrs fw_head-budat va_fakno gv_header-budat
                      CHANGING gv_header-fakno.

  PERFORM f_get_spell_amount USING fw_head-grossamt 'IDR'
                             CHANGING gv_header-terbilang.

  LOOP AT ft_item.
    ADD 1 TO gt_detail-norut.
    CONCATENATE ft_item-txt1 ft_item-txt2 INTO gt_detail-maktx SEPARATED BY space.
    WRITE ft_item-kzwi1 TO gt_detail-jumlah CURRENCY 'IDR'.
    APPEND gt_detail.
  ENDLOOP.
  CLEAR gt_detail.
  gt_detail-maktx = 'Jasa Pembelian:'.
  INSERT gt_detail INDEX 1.
  INSERT INITIAL LINE INTO gt_detail INDEX 1.
  INSERT INITIAL LINE INTO gt_detail INDEX 1.
ENDFORM.                    " F_MOVE_TO_NEW_FAKTUR_TNT

*&---------------------------------------------------------------------*
*&      Form  F_GET_FAKNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_fakno  USING    fu_belnr fu_bukrs fu_budat fu_fakno fu_fakdat
                  CHANGING fc_fakno.
  DATA: ld_vattrn    LIKE zfvattrn-vattrn,
        ld_vatbr     LIKE zfvattrn-vatbr,
        ld_vatno     LIKE zfvatnr-vatno,
        ld_fakno(17),
        ld_vatcd     LIKE zfvatnr-vatcd.

  IF fu_budat IN gr_coretax.
    SELECT SINGLE fakturno
      FROM zcoretax0005
      INTO fc_fakno
      WHERE bukrs = fu_bukrs
        AND belnr = fu_belnr.
    IF sy-subrc = 0.
      WRITE fc_fakno TO fc_fakno USING EDIT MASK '__.__.__.___-________'.
    ENDIF.
  ELSE.
    IF fu_fakno IS INITIAL.
      SELECT SINGLE fakturno
        FROM zgdtxdt0011
        INTO ld_fakno
        WHERE brnch    EQ fu_bukrs  AND
              objrange EQ 'ZGDTXNR001'.

      IF sy-subrc EQ 0.
        CONCATENATE ld_fakno(3) '.' ld_fakno+3(3) '.' INTO fc_fakno.
        CONCATENATE fc_fakno ld_fakno+6(2) '.' ld_fakno+8(8) INTO fc_fakno.

      ELSE.
        SELECT SINGLE vattrn vatbr
           FROM zfvattrn
             INTO (ld_vattrn, ld_vatbr)
           WHERE vkorg EQ fu_bukrs AND
                 gform EQ 'A1'.

        IF sy-subrc EQ 0.
          IF fu_budat > gs_dpp-datab.
            IF ld_vattrn = '01'.
              ld_vattrn = '04'.
            ENDIF.
          ENDIF.

          SELECT SINGLE vatno vatcd
                 FROM zfvatnr
                 INTO (ld_vatno, ld_vatcd)
               WHERE vkorg EQ fu_bukrs AND
                     vkbur EQ '000'        AND
                     gjahr EQ fu_budat(4).

          ld_vatno = ld_vatno + 1.
          CONCATENATE ld_vattrn '0' ld_vatcd fu_budat+2(2) ld_vatno
          INTO ld_fakno.

          CONCATENATE ld_fakno(3) '.' ld_fakno+3(3) '.' INTO fc_fakno.
          CONCATENATE fc_fakno ld_fakno+6(2) '.' ld_fakno+8(8) INTO fc_fakno.
        ENDIF.
      ENDIF.
    ELSE.
      IF fu_budat IN gr_coretax.
        WRITE fu_fakno TO fc_fakno USING EDIT MASK '__.__.__.___-________'.
      ELSE.
        WRITE fu_fakno TO fc_fakno USING EDIT MASK '___.___.__.________'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_FAKNO

*&---------------------------------------------------------------------*
*&      Form  F_GET_SPELL_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_spell_amount  USING    fu_kzwi4
                                  fu_curr
                         CHANGING fc_terbilang.
  DATA lv_spell LIKE spell.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount   = fu_kzwi4
      currency = fu_curr
*     FILLER   = ' '
      language = 'i'
    IMPORTING
      in_words = lv_spell.
  IF sy-subrc = 0.
    CONCATENATE lv_spell-word 'RUPIAH' INTO fc_terbilang SEPARATED BY space.
    CONCATENATE '##' fc_terbilang '##' INTO fc_terbilang SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_SPELL_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_ROUND_DOWN
*&---------------------------------------------------------------------*
FORM f_round_down  USING    fu_value
                   CHANGING fc_value.

  CALL FUNCTION 'ROUND'
    EXPORTING
      decimals      = 2
      input         = fu_value
      sign          = '-'
    IMPORTING
      output        = fc_value
    EXCEPTIONS
      input_invalid = 1
      overflow      = 2
      type_invalid  = 3
      OTHERS        = 4.
ENDFORM.                    " F_ROUND_DOWN

*&---------------------------------------------------------------------*
*&      Form  F_NEW_PPN11
*&---------------------------------------------------------------------*
FORM f_new_ppn11 USING    fu_budat.
  DATA : ls_a003 TYPE a003,
         ls_konp TYPE konp.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_calty = 'TC1'
      pi_datum = fu_budat
    IMPORTING
      po_mwskz = d_taxcode.

  CLEAR ls_a003.
  READ TABLE gt_a003 INTO ls_a003
                     WITH KEY mwskz = d_taxcode.
  IF sy-subrc = 0.
    CLEAR ls_konp.
    READ TABLE gt_konp INTO ls_konp
                       WITH KEY knumh = ls_a003-knumh.
    IF sy-subrc = 0.
      d_tax = ls_konp-kbetr / 10.
*      WRITE d_tax TO fc_tax DECIMALS 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NEW_PPN11

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST  INPUT
*&---------------------------------------------------------------------*
MODULE value_request INPUT.
  PERFORM f_f4_value_request.


ENDMODULE.                 " VALUE_REQUEST  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_F4_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_f4_value_request .
  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  TYPES : BEGIN OF ty_0025,
            kunnr   TYPE zgdtxdt0025-kunnr,
            kidno   TYPE zgdtxdt0025-kidno,
            name_co TYPE zgdtxdt0025-name_co,
          END OF ty_0025.

  DATA : lt_x0025 TYPE STANDARD TABLE OF ty_0025,
         ls_x0025 LIKE LINE OF lt_x0025,
         ls_0025  LIKE LINE OF gt_0025,
         lv_subrc TYPE sy-subrc,
         lv_kidno TYPE bseg-kidno.

  LOOP AT gt_0025 INTO ls_0025.
    MOVE-CORRESPONDING ls_0025 TO ls_x0025.
    APPEND ls_x0025 TO lt_x0025.
    CLEAR ls_x0025.
  ENDLOOP.

  ASSIGN lt_x0025[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KIDNO' 'BSEG-KIDNO'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.

    lv_kidno = ls_return-fieldval.
    READ TABLE lt_x0025 INTO ls_x0025
                        WITH KEY kidno = lv_kidno.
    IF sy-subrc = 0.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'BSEG-KIDNO' ls_x0025-kidno ''.
    ENDIF.

    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_F4_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFIKASI_ALAMAT
*&---------------------------------------------------------------------*
FORM f_modifikasi_alamat  USING    fu_kidno
                          CHANGING fc_name_co fc_str_suppl1 fc_str_suppl2
                                   fc_str_suppl3 fc_location.
  DATA : ls_0025  LIKE LINE OF gt_0025.

  IF fu_kidno IS NOT INITIAL.
    CLEAR ls_0025.
    READ TABLE gt_0025 INTO ls_0025
                       WITH KEY kunnr = t_crb_head-kunnr
                                kidno = fu_kidno.
    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM zgdtxdt0025
        INTO CORRESPONDING FIELDS OF ls_0025
        WHERE kunnr = t_crb_head-kunnr
          AND kidno = fu_kidno.
    ENDIF.

    fc_name_co    = ls_0025-name_co.
    fc_str_suppl1 = ls_0025-str_suppl1.
    fc_str_suppl2 = ls_0025-str_suppl2.
    fc_str_suppl3 = ls_0025-str_suppl3.
    fc_location   = ls_0025-location.
  ENDIF.
ENDFORM.                    " F_MODIFIKASI_ALAMAT

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_VALIDATE
*&---------------------------------------------------------------------*
FORM f_coretax_validate .
  DATA : ls_project TYPE zproject,
         ls_coretax LIKE LINE OF gr_coretax.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'CORETAX'.
  ls_coretax-low = ls_project-datab.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'ZGDCORETAX'.
  ls_coretax-high   = ls_project-datab.
  ls_coretax-sign   = 'I'.
  ls_coretax-option = 'BT'.
  APPEND ls_coretax TO gr_coretax.
ENDFORM.
