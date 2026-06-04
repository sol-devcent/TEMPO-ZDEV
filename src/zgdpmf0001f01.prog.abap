*----------------------------------------------------------------------*
*   INCLUDE ZGDPMF0001F01                                              *
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

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
***added by Rahmadi to sort by end date for MO Conf
  IF NOT d_sort_date IS INITIAL.
    SORT iafvgd BY iedd iedz.
  ENDIF.
***end of addition
  IF op_print_tab IS INITIAL.
    IF t390-workpaper = '2010'.
      PERFORM f_print_form.
    ELSE.
      PERFORM f_print_form1.
    ENDIF.
  ELSE.
    PERFORM f_cek_operation.
    PERFORM f_print_form.
  ENDIF.
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
  p_tdform = c_form.
  p_dest   = wworkpaper-tddest.
  IF device = 'PREVIEW'.
    p_disp = 'X'.
  ELSE.
    p_disp = space.
  ENDIF.
  CLEAR: d_caufv, d_viqmel, d_afvc, d_afvv.
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
  DATA: l_name(70),
        l_count TYPE i,
        l_lines TYPE i.

* get header data
  SELECT SINGLE * FROM caufv
  INTO CORRESPONDING FIELDS OF d_caufv
  WHERE aufnr = p_aufnr.

* get notification data
  SELECT SINGLE * FROM viqmel
  INTO CORRESPONDING FIELDS OF d_viqmel
  WHERE aufnr = p_aufnr.

* get requestor number
  IF d_viqmel IS NOT INITIAL.
    SELECT SINGLE * FROM qmfe
    INTO CORRESPONDING FIELDS OF d_qmfe
    WHERE qmnum = d_viqmel-qmnum.
  ENDIF.

* get operation data
  SELECT SINGLE * FROM afvc
  INTO CORRESPONDING FIELDS OF d_afvc
  WHERE aufpl = d_caufv-aufpl
  AND   vornr = p_vornr.
*  AND   loekz <> 'X'.

* get material data
  SELECT * FROM resb
  INTO CORRESPONDING FIELDS OF TABLE t_resb
  WHERE rsnum = d_caufv-rsnum
  AND   vornr = p_vornr
  AND   xloek <> 'X'.

* delete material where matnr is in header
  IF NOT caufvd-matnr IS INITIAL.
    DELETE t_resb WHERE matnr = caufvd-matnr.
  ENDIF.

* filter material by material type
* ZSPR - Spare parts,
* ZNV - Non valuated
  DATA: BEGIN OF lt_matfiltered OCCURS 1,
    matnr LIKE mara-matnr,
    mtart LIKE mara-mtart,
    bklas LIKE mbew-bklas.
  DATA END OF lt_matfiltered.
  DATA lt_resb LIKE t_resb OCCURS 1 WITH HEADER LINE.

  IF NOT t_resb[] IS INITIAL.
    lt_resb[] = t_resb[].
    SORT lt_resb BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_resb
      COMPARING matnr.

    SELECT m~matnr m~mtart w~bklas
      INTO CORRESPONDING FIELDS OF TABLE lt_matfiltered
      FROM mara AS m
      INNER JOIN mbew AS w ON
      m~matnr = w~matnr
      FOR ALL ENTRIES IN lt_resb
      WHERE m~matnr = lt_resb-matnr. " AND
*          ( m~mtart = 'ZRSA' OR
*            m~mtart = 'ZRHI' OR
*            m~mtart = 'ZRHD' ).

****CR#1 No need to consider valuation class anymore
****CR#2 Need to consider valuation class '4103' only for ZRHD
    DELETE lt_matfiltered WHERE
     ( mtart <> 'ZSPR' ) AND
     ( mtart <> 'ZNV' ).
*     ( mtart <> 'ZRHI' OR bklas <> '4203' ) AND
****changed by Rahmadi 03/05/2004 - requested by Effendy
****include all ZRHD & ZALB
*     ( mtart <> 'ZRHD' OR bklas <> '4103' ).
****end of change

    SORT lt_matfiltered BY matnr.
    LOOP AT lt_resb.
      CLEAR lt_matfiltered.
      READ TABLE lt_matfiltered WITH KEY matnr = lt_resb-matnr
        BINARY SEARCH.

      IF sy-subrc <> 0.
        DELETE t_resb WHERE matnr = lt_resb-matnr AND postp <> 'N'.
      ENDIF.
    ENDLOOP.
  ENDIF.
* get quantities/dates/values in the operation
  IF NOT d_afvc IS INITIAL.
    SELECT SINGLE * FROM afvv
    INTO CORRESPONDING FIELDS OF d_afvv
    WHERE aufpl = d_afvc-aufpl
    AND   aplzl = d_afvc-aplzl.
  ENDIF.
*{   INSERT         P01K900131                                        1
*    Start modification by sap_dev04 09/04/07 to clear/refresh the content of i_line
  CLEAR i_line.
  REFRESH i_line.
*}   INSERT

* Get long text
  LOOP AT iafvgd.
* Modify start date & finish date
    IF t390-workpaper = '2070' AND
      caufvd-sttxt CS 'CNF'.
      SELECT aufnr isdd isdz iedd iedz
        FROM afru
        INTO CORRESPONDING FIELDS OF TABLE i_afru
        WHERE aufnr EQ iafvgd-aufnrd AND
              aplzl EQ iafvgd-aplzl.
      IF sy-subrc EQ 0.
        DESCRIBE TABLE i_afru LINES l_lines.
        READ TABLE i_afru INTO wa_afru INDEX l_lines.
        IF sy-subrc EQ 0.
          iafvgd-isdd = wa_afru-isdd.
          iafvgd-isdz = wa_afru-isdz.
          iafvgd-iedd = wa_afru-iedd.
          iafvgd-iedz = wa_afru-iedz.
        ENDIF.
        MODIFY iafvgd TRANSPORTING isdd isdz iedd iedz.
      ENDIF.
    ENDIF.

    CONCATENATE iafvgd-mandt iafvgd-aufpl iafvgd-aplzl
      INTO l_name.

    l_count = 0.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'AVOT'
        language                = sy-langu
        name                    = l_name
        object                  = 'AUFK'
      TABLES
        lines                   = t_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      LOOP AT t_lines.
        IF l_count = 0.
          l_count = 1.
        ELSE.
          IF t_lines-tdline NE space.
            wa_line-aufpl  = iafvgd-aufpl.
            wa_line-aplzl  = iafvgd-aplzl.
            wa_line-tdline = t_lines-tdline.
            APPEND wa_line TO i_line.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
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
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_output_opt-tdimmed = wworkpaper-tdimmed.

  IF device = 'PREVIEW'.
    d_output_opt-tdnoprint = 'X'.
  ENDIF.

  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
* call the generated function module of the form
    LOOP AT iafvgd.

* One Spool
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

* to cater multiple printing
      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          d_caufv            = d_caufv
          d_viqmel           = d_viqmel
          d_qmfe             = d_qmfe
          d_afvc             = d_afvc
          d_afvv             = d_afvv
          d_pmpl             = pmpl
          caufvd             = caufvd
          iloa               = iloa
        TABLES
          iafvgd             = iafvgd
          iresbd             = iresbd
          t_resb             = t_resb
          t_line             = t_line
          i_line             = i_line.

* One Spool
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
  CLEAR: d_caufv, d_viqmel, d_afvc, d_afvv.
  REFRESH: t_resb, iafvgd, iresbd.
ENDFORM.                    " f_free_memory
*&---------------------------------------------------------------------*
*&      Form  f_update_pmpl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_update_pmpl.
  CALL FUNCTION 'PM_UPDATE_PMPL'
    EXPORTING
      indupd                  = 'I'
      wpmpl                   = pmpl
    EXCEPTIONS
      invalid_generic_action  = 1
      invalid_parameter       = 2
      key_not_fully_specified = 3
      OTHERS                  = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_EPMPL'
   EXPORTING
*     MODE_PMPL         = 'E'
*     MANDT             = SY-MANDT
     pm_appl              = t390-pm_appl
     print_key            = pmpl-print_key
     pm_paper             = pmpl-pm_paper
*     COPY_NR           =
*     X_PM_APPL         = ' '
*     X_PRINT_KEY       = ' '
*     X_PM_PAPER        = ' '
*     X_COPY_NR         = ' '
*     _SCOPE            = '3'
*     _SYNCHRON         = ' '
*     _COLLECT          = ' '
            .

ENDFORM.                    " f_update_pmpl

*&---------------------------------------------------------------------*
*&      Form  f_get_pmpl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_pmpl.

  CLEAR pmpl.                          " Clear log record.

  CALL FUNCTION 'PM_BUILD_PRINT_KEY'
    EXPORTING
      afvgd                      = iafvgd
      caufvd                     = caufvd
      pm_appl                    = t390-pm_appl
      prt_depth                  = header
    IMPORTING
      pmpl                       = pmpl
    EXCEPTIONS
      appropriate_tables_missing = 1
      invalid_build_options      = 2
      invalid_pm_application     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SELECT MAX( copy_nr )
  FROM pmpl
  INTO pmpl-copy_nr
  WHERE pm_appl = t390-pm_appl
  AND   pm_paper = t390-workpaper
  AND   print_key = p_aufnr.

  ADD 1 TO pmpl-copy_nr.

  pmpl-form     = t390-form.
  pmpl-pm_paper = t390-workpaper.
  pmpl-uname    = sy-uname.
  pmpl-datum    = sy-datum.
  pmpl-uzeit    = sy-uzeit.
  pmpl-tddest   = wworkpaper-tddest.

  IF p_disp = space.
    CALL FUNCTION 'ENQUEUE_EPMPL'
   EXPORTING
*     MODE_PMPL            = 'E'
*     MANDT                = SY-MANDT
     pm_appl              = t390-pm_appl
     print_key            = pmpl-print_key
     pm_paper             = pmpl-pm_paper
*     COPY_NR              =
*     X_PM_APPL            = ' '
*     X_PRINT_KEY          = ' '
*     X_PM_PAPER           = ' '
*     X_COPY_NR            = ' '
*     _SCOPE               = '2'
*     _WAIT                = ' '
*     _COLLECT             = ' '
   EXCEPTIONS
     foreign_lock         = 1
     system_failure       = 2
     OTHERS               = 3
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_get_pmpl
*
*&---------------------------------------------------------------------*
*&      Form  print_paper
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_paper.
  REFRESH: op_print_tab.
  CLEAR: op_print_tab, d_sort_date.

  PERFORM f_import_data.

* import data from the screen transaction
  CONDENSE caufvd-auart.

* PM02 print condition
  IF caufvd-auart = 'PM02'.
    IF caufvd-sttxt NS 'NMAT'.
* System status not NMAT
      IF op_print_tab IS INITIAL AND
        t390-workpaper = '2030'.
* Print Preventive Maintenance Order
        p_vornr = op_print_tab-vornr.
        c_form = 'ZGDPMF0001_02'.
        PERFORM f_process_report.

        IF p_disp = space.
          PERFORM f_update_pmpl.
        ENDIF.
      ELSEIF NOT op_print_tab IS INITIAL AND
        t390-workpaper EQ '2010'.
* Print Maintenance Order
        LOOP AT op_print_tab.
          p_vornr = op_print_tab-vornr.
          c_form = 'ZGDPMF0001_01'.
          PERFORM f_process_report.
        ENDLOOP.

        IF p_disp = space.
          PERFORM f_update_pmpl.
        ENDIF.
      ELSE.
*    MESSAGE s000 WITH 'Order type is not PM31 and not PM34'.
        CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
          EXPORTING
            msg_arbgb         = 'ZGDPM'
            msg_nr            = '000'
            msg_ty            = 'S'
            msg_v1            = 'Order is not printed,'
            msg_v2            = 'its type is not PM02.'
*   MSG_V3                       = ' '
*   MSG_V4                       = ' '
          EXCEPTIONS
            message_type_not_valid       = 1
            no_sy_message                = 2
            OTHERS                       = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ELSE.
* System status NMAT
* Print Preventive Maintenance Order
      IF op_print_tab IS INITIAL AND
        t390-workpaper = '2030'.
        p_vornr = op_print_tab-vornr.
        c_form = 'ZGDPMF0001_02'.
        PERFORM f_process_report.

        IF p_disp = space.
          PERFORM f_update_pmpl.
        ENDIF.
      ELSE.
*    MESSAGE s000 WITH 'Order type is not PM31 and not PM34'.
        CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
          EXPORTING
            msg_arbgb         = 'ZGDPM'
            msg_nr            = '000'
            msg_ty            = 'S'
            msg_v1            = 'Order is not printed,'
            msg_v2            = 'its type is not PM02.'
*     MSG_V3                       = ' '
*     MSG_V4                       = ' '
         EXCEPTIONS
           message_type_not_valid       = 1
           no_sy_message                = 2
           OTHERS                       = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Maintenance Order
  IF t390-workpaper = '2010'.
    IF caufvd-auart = 'PM01' OR caufvd-auart = 'PM03' OR
       caufvd-auart = 'PM04' OR caufvd-auart = 'PM05'. "OR
*       ( caufvd-auart = 'PM02' AND caufvd-sttxt CS 'GMPS' ).
*       ( caufvd-auart = 'PM02' AND caufvd-sttxt NS 'NMAT' ).

      IF caufvd-auart NE 'PM04'.
        caufvd-matxt = space.
        caufvd-gamng = 0.
      ENDIF.

      LOOP AT op_print_tab.
        p_vornr = op_print_tab-vornr.
        c_form = 'ZGDPMF0001_01'.
        PERFORM f_process_report.
      ENDLOOP.

      IF op_print_tab IS INITIAL.
        p_vornr = op_print_tab-vornr.
        c_form = 'ZGDPMF0001_01'.
        PERFORM f_process_report.
      ENDIF.

      IF p_disp = space.
        PERFORM f_update_pmpl.
      ENDIF.
    ELSE.
*    MESSAGE s000 WITH 'Order type is not PM31 and not PM34'.
      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
          msg_arbgb         = 'ZGDPM'
          msg_nr            = '000'
          msg_ty            = 'S'
          msg_v1            = 'Order is not printed,'
          msg_v2            = 'its type is not PM01,PM03,PM04 nor PM05.'
*   MSG_V3                       = ' '
*   MSG_V4                       = ' '
       EXCEPTIONS
         message_type_not_valid       = 1
         no_sy_message                = 2
         OTHERS                       = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.

* Maintenance Order Confirmation ( Serah Terima )
  IF t390-workpaper = '2070' AND
    caufvd-sttxt CS 'CNF'.
***removed by Rahmadi 21/04/2005 -- requested by Effendy
***to include all types of orders (no restriction anymore)
*    IF caufvd-auart = 'PM01' OR caufvd-auart = 'PM03' OR
*       caufvd-auart = 'PM05'.
    p_vornr = op_print_tab-vornr.
    c_form = 'ZGDPMF0001_03'.

***added by Rahmadi -- sort by date
    d_sort_date = 'X'.     "sorted by End date for MO Confirmation
***end of addition

    PERFORM f_process_report.

    IF p_disp = space.
      PERFORM f_update_pmpl.
    ENDIF.
*    ELSE.
**    MESSAGE s000 WITH 'Order type is not PM31 and not PM34'.
*      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*        EXPORTING
*          msg_arbgb         = 'ZGDPM'
*          msg_nr            = '000'
*          msg_ty            = 'S'
*          msg_v1            = 'Order is not printed,'
*          msg_v2            = 'its type is not PM01,PM03,PM05.'
**   MSG_V3                       = ' '
**   MSG_V4                       = ' '
*       EXCEPTIONS
*         message_type_not_valid       = 1
*         no_sy_message                = 2
*         OTHERS                       = 3.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ENDIF.
  ENDIF.
ENDFORM.                    " print_paper
*&---------------------------------------------------------------------*
*&      Form  f_import_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_import_data.
* import data shop paper from the transaction
  IMPORT
    wworkpaper
    t390
    device
    print_language
    sy_uname
    sy_datum
    FROM   MEMORY ID id_iprt_options.

  PERFORM only_order_data_import IN PROGRAM riprct00
      TABLES
       op_print_tab
       kbedp_tab
       ihpad_tab
       ihsg_tab
       ihgns_tab
       iafvgd
       iripw0
       iresbd
       iaffhd
      CHANGING
       caufvd
       riwo1
       iloa.

* keep the selected operation only
  DELETE op_print_tab WHERE flg_sel = space.
  READ TABLE:
    op_print_tab INDEX 1,
    iafvgd WITH KEY vornr = op_print_tab-vornr.

  p_aufnr = caufvd-aufnr.
  PERFORM f_get_pmpl.

ENDFORM.                    " f_import_data

*&---------------------------------------------------------------------*
*&      Form  f_print_form1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form1.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_output_opt-tdimmed = wworkpaper-tdimmed.

  IF device = 'PREVIEW'.
    d_output_opt-tdnoprint = 'X'.
  ENDIF.

  IF d_frm_subrc IS INITIAL.
*      call the generated function module of the form
* call the generated function module of the form
    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        d_caufv            = d_caufv
        d_viqmel           = d_viqmel
        d_qmfe             = d_qmfe
        d_afvc             = d_afvc
        d_afvv             = d_afvv
        d_pmpl             = pmpl
        caufvd             = caufvd
        iloa               = iloa
      TABLES
        iafvgd             = iafvgd
        iresbd             = iresbd
        t_resb             = t_resb
        t_line             = t_line
        i_line             = i_line.
  ENDIF.
ENDFORM.                    " f_print_form1

*&---------------------------------------------------------------------*
*&      Form  f_cek_operation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_operation.
  LOOP AT iafvgd.
    READ TABLE op_print_tab WITH KEY vornr = iafvgd-vornr.
    IF sy-subrc NE 0.
      DELETE iafvgd WHERE vornr EQ iafvgd-vornr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_cek_operation
