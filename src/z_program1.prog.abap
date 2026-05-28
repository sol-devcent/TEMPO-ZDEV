*&---------------------------------------------------------------------*
*&  Include           Z_PROGRAM1
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: p_werks LIKE caufvd-werks MODIF ID pwe.
PARAMETERS: p_umlgo LIKE resb-lgort OBLIGATORY DEFAULT '1000'
                      MODIF ID xxx.
PARAMETERS: p_lgort LIKE resb-lgort MODIF ID plg.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
SELECT-OPTIONS: s_aufnr FOR resb-aufnr, "  OBLIGATORY ,
                s_plnbez FOR caufvd-plnbez.
SELECT-OPTIONS: s_fevor FOR caufvd-fevor NO INTERVALS.
SELECT-OPTIONS:   s_gstrp  FOR resb-bdter." OBLIGATORY.
PARAMETERS: p_mtart LIKE mara-mtart OBLIGATORY DEFAULT 'ZRM'.

SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
PARAMETERS: p_vari  LIKE disvariant-variant.
PARAMETERS: p_chk1 AS CHECKBOX DEFAULT ' '.

SELECTION-SCREEN END OF BLOCK data1.
SELECTION-SCREEN END OF SCREEN 100.

SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
*   SELECT-OPTIONS: s_rsnum FOR Resb-rsnum.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
  USER-COMMAND skd DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(25) text-003 FOR FIELD radio1.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : s_rsnum FOR resb-rsnum MODIF ID tb1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 4(25) text-005 FOR FIELD radio1.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : s_gstrp1 FOR sy-datum MODIF ID tb1  .
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(25) text-004 FOR FIELD radio2.
SELECTION-SCREEN POSITION 33.
PARAMETERS: p_rsnum LIKE zgdppdt0001-rsnum MODIF ID tb2 .
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(25) text-006 FOR FIELD radio3.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : s_rsnum1 FOR resb-rsnum MODIF ID tb3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF SCREEN 200.

SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
SELECT-OPTIONS so_aufnr   FOR caufv-aufnr
                          MODIF ID sau.
PARAMETERS pa_mtart LIKE mara-mtart OBLIGATORY DEFAULT 'ZRM'
                    MODIF ID pmt.

SELECTION-SCREEN SKIP 1.
PARAMETERS pa_order AS CHECKBOX DEFAULT 'X' MODIF ID ord.
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF SCREEN 300.

SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 20 LINES,
                  TAB (20) button1 USER-COMMAND push1,
                  TAB (20) button2 USER-COMMAND push2,
                  TAB (25) button3 USER-COMMAND push3,
                  END OF BLOCK mytab.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  mytab-prog = sy-repid.
  mytab-dynnr = 100.
  mytab-activetab = 'BUTTON1'.
  button1 = text-100.
  button2 = text-200.
  button3 = text-300.
  option = 1.
*  p_mtart-low = 'ZPM'.
*  p_mtart-option = 'EQ'.
*  p_mtart-sign   = 'I'.
*  append p_mtart.
* p_mtart-low = 'ZRM'.
* p_mtart-option = 'EQ'.
* p_mtart-sign   = 'I'.
* append p_mtart.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON p_date.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'XXX'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  LOOP AT SCREEN.
    IF screen-group1 = 'ORD'.
      screen-active  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF option = 2.
    LOOP AT SCREEN.
      IF radio1 = 'X'.
        IF  screen-group1 = 'TB2'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-group1 = 'TB3'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF radio2 = 'X'..
        IF  screen-group1 = 'TB1'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-group1 = 'TB3'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF radio3 = 'X'.
        IF  screen-group1 = 'TB2'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-group1 = 'TB1'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  if p_lgort = '2900'.
*  LOOP AT SCREEN.
*    IF screen-group1 = 'XXX'.
*      screen-input  = 1.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
*  endif.
*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON BLOCK data.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'PUSH1'.
          mytab-dynnr = 100.
          mytab-activetab = 'BUTTON1'.
          option = 1.
        WHEN 'PUSH2'.
          mytab-dynnr = 200.
          mytab-activetab = 'BUTTON2'.
          option = 2.
        WHEN 'PUSH3'.
          mytab-dynnr = 300.
          mytab-activetab = 'BUTTON3'.
          option = 3.
      ENDCASE.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

AT SELECTION-SCREEN ON p_werks.
*-Authorization
  macro_atz_single_werks p_werks c_atz_display.

AT SELECTION-SCREEN ON p_mtart.

AT SELECTION-SCREEN ON s_fevor.
***comment by Rahmadi: Sebisa mungkin jangan select *, krn field CAUFV
***banyuak banget
  SELECT *
    FROM caufv
    INTO CORRESPONDING FIELDS OF TABLE i_caufv
    WHERE aufnr  IN s_aufnr AND
          autyp  EQ '40' AND
          werks  EQ p_werks AND
          plnbez IN s_plnbez AND
          fevor  IN s_fevor AND
          gstrp  IN s_gstrp.

  DELETE i_caufv WHERE plnbez = space.
  DELETE i_caufv WHERE plnbez IS INITIAL.
* add by MKO to improve performance
  DELETE i_caufv WHERE idat2 <> '00000000'.
  DELETE i_caufv WHERE loekz = 'X'.
* end add

  IF i_caufv[] IS NOT INITIAL.
    SELECT * FROM zgdppdt0001
      INTO CORRESPONDING FIELDS OF TABLE i_zgdppdt0001
      FOR ALL ENTRIES IN i_caufv
          WHERE aufnr = i_caufv-aufnr AND
                nctrl <> 'C'.
  ENDIF.

  SORT i_zgdppdt0001  BY aufnr matnr.
  sw = 1.
  LOOP AT i_caufv INTO wa_caufv.
    IF wa_caufv-plnbez IS INITIAL.
      DELETE i_caufv.
      CONTINUE.
    ENDIF.
    SORT i_zgdppdt0001 BY aufnr matnr fevor mtart lgort.
    READ TABLE i_zgdppdt0001 INTO wa_zgdppdt0001 WITH
        KEY aufnr = wa_caufv-aufnr
            matnr = wa_caufv-plnbez
            fevor = wa_caufv-fevor
            mtart = p_mtart
            lgort = p_lgort
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      DELETE i_caufv.
      CONTINUE.
    ENDIF.
    SELECT SINGLE * FROM jest
           WHERE objnr = wa_caufv-objnr AND
                 ( stat  = 'I0001' OR stat  = 'I0002' ) AND
                 inact EQ space.
    IF sy-subrc EQ 0.
      IF p_werks = '0901'.
        IF sw = 1 AND wa_caufv-fevor NE 'LQD'.
          sw = 2.
        ENDIF.
        IF sw = 2 AND wa_caufv-fevor EQ 'LQD'.
          sw = 3.
        ENDIF.
      ENDIF.
      CONTINUE.
    ELSE.
      DELETE i_caufv.
    ENDIF.
  ENDLOOP.

  IF p_lgort = '2900'.
    p_umlgo = '1900'.
  ELSE.
    IF i_caufv[] IS INITIAL.
      IF s_fevor-low = 'LQD' AND p_werks = '0901'.
        p_umlgo = '1001'.
      ELSE.
        p_umlgo = '1000'.
      ENDIF.
    ELSE.
      IF sw = 3.
        MESSAGE e010(zz)
          WITH 'Salah Kombinasi untuk Production Scheduler'.
        EXIT.
      ENDIF.

* Sloc 1001 sudah tidak digunakan khusus untuk FEVOR LQD
*        IF p_werks = '0901' AND sw = 1.
*          p_umlgo = '1001'.
*        ELSE.
*          p_umlgo = '1000'.
*        ENDIF.
    ENDIF.
  ENDIF.


AT SELECTION-SCREEN ON p_lgort.
  IF p_werks = '0901'.
    IF s_fevor IS INITIAL.
    ELSE.
      IF s_fevor-low = 'LQD'.
        IF p_lgort EQ '2300' OR p_lgort EQ '2400' OR p_lgort EQ '2900'.
        ELSE.
          MESSAGE e010(zz) WITH 'S Loc. Dest. = 2300/2400/2900'.
        ENDIF.
      ELSE.
        IF p_lgort NE '2300' AND p_lgort NE '2400'.
        ELSE.
          MESSAGE e010(zz) WITH 'S Loc. Dest. = 2100/2200/2500/2900'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA : lv_subrc   TYPE sy-subrc,
         oref       TYPE REF TO cx_root,
         lv_message(100).

  PERFORM f_init_data.
  PERFORM f_get_data.

  CASE option.
    WHEN 1.
      CLEAR: radio1, radio2, radio3.
      IF i_caufv[] IS INITIAL.
        MESSAGE i010(zz) WITH 'No Data'.
        EXIT.
      ENDIF.

      PERFORM f_validate_data.

      IF i_itab1[] IS INITIAL.
*        PERFORM f_add_aufnr_for_change_status.
        IF i_status[] IS NOT INITIAL.
          PERFORM f_add_new_status.
          PERFORM f_change_status.
          MESSAGE i010(zz) WITH 'Stock available'.
          EXIT.
        ENDIF.
      ENDIF.

      IF p_chk1 = 'X'.
*      PERFORM f_validate_data_bapi.
        PERFORM f_new_validate_data_bapi.
        PERFORM f_save_to_table.
        PERFORM print.
      ELSE.
        PERFORM f_print_data.
      ENDIF.

    WHEN 2.
      IF radio1 = 'X'.
        IF i_zgdppdt0001[] IS INITIAL.
          MESSAGE i010(zz) WITH 'No Data'.
          EXIT.
        ENDIF.
        PERFORM f_validate_data21.
        PERFORM f_write_result.
      ENDIF.

      IF radio2 = 'X'.
        IF p_werks = '0101' OR p_werks = '0102' OR
           p_werks = '0901'.
          IF i_zgdppdt0001[] IS INITIAL.
            MESSAGE i010(zz) WITH 'No Data'.
            EXIT.
          ENDIF.
          PERFORM f_validate_data21.
          PERFORM f_get_resb.
          PERFORM f_write_result.
        ELSE.
          IF i_zgdppdt0001[] IS INITIAL.
            IF gv_subrc = 1.
              MESSAGE i010(zz) WITH 'TO already create'.
            ELSE.
              MESSAGE i010(zz) WITH 'No Data'.
            ENDIF.
            EXIT.
          ENDIF.
          REFRESH: i_bapireturn1.
          CLEAR: i_bapireturn1.
          LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001.
            CALL FUNCTION 'BAPI_RESERVATION_DELETE'
              EXPORTING
                reservation = wa_zgdppdt0001-rsnum
              TABLES
                return      = i_bapireturn1
              EXCEPTIONS
                OTHERS      = 1.
            IF i_bapireturn1 IS INITIAL.
****            COMMIT WORK.
****            SELECT * FROM zgdppdt0001
****                WHERE werks = wa_zgdppdt0001-werks AND
****                      rsnum = wa_zgdppdt0001-rsnum AND
****                      gstrp = wa_zgdppdt0001-gstrp AND
****                      matnr = wa_zgdppdt0001-matnr AND
****                      aufnr = wa_zgdppdt0001-aufnr AND
****                      charg = wa_zgdppdt0001-charg AND
****                      lgort = wa_zgdppdt0001-lgort.
****              zgdppdt0001-nctrl = 'C'.
****              MODIFY zgdppdt0001.
****            ENDSELECT.

              PERFORM f_change_detail_status USING wa_zgdppdt0001-rsnum
                                                   wa_zgdppdt0001-aufnr
                                             CHANGING lv_subrc.
              IF lv_subrc IS INITIAL.
                TRY .
                    UPDATE zgdppdt0001 SET nctrl = 'C'
                                        WHERE werks = wa_zgdppdt0001-werks
                                          AND rsnum = wa_zgdppdt0001-rsnum
                                          AND gstrp = wa_zgdppdt0001-gstrp
                                          AND matnr = wa_zgdppdt0001-matnr
                                          AND aufnr = wa_zgdppdt0001-aufnr
                                          AND charg = wa_zgdppdt0001-charg
                                          AND lgort = wa_zgdppdt0001-lgort.
                  CATCH cx_sy_open_sql_db INTO oref.
                    lv_message = oref->get_text( ).
                ENDTRY.

                IF lv_message IS INITIAL.
                  COMMIT WORK AND WAIT.
                ELSE.
                  ROLLBACK WORK.
                ENDIF.
              ENDIF.
            ELSE.
              LOOP AT i_bapireturn1 INTO wa_bapireturn1.
                IF wa_bapireturn-type  = 'E'.
                  MESSAGE i000(zgd) WITH wa_bapireturn-message.
                  EXIT.
                ELSE.
****                SELECT * FROM zgdppdt0001
****                    WHERE werks = wa_zgdppdt0001-werks AND
****                          rsnum = wa_zgdppdt0001-rsnum AND
****                          gstrp = wa_zgdppdt0001-gstrp AND
****                          matnr = wa_zgdppdt0001-matnr AND
****                          aufnr = wa_zgdppdt0001-aufnr AND
****                          charg = wa_zgdppdt0001-charg AND
****                          lgort = wa_zgdppdt0001-lgort.
****                  zgdppdt0001-nctrl = 'C'.
****                  MODIFY zgdppdt0001.
****                ENDSELECT.
****                COMMIT WORK.

                  PERFORM f_change_detail_status USING wa_zgdppdt0001-rsnum
                                                       wa_zgdppdt0001-aufnr
                                                 CHANGING lv_subrc.
                  IF lv_subrc IS INITIAL.
                    TRY .
                        UPDATE zgdppdt0001 SET nctrl = 'C'
                                            WHERE werks = wa_zgdppdt0001-werks
                                              AND rsnum = wa_zgdppdt0001-rsnum
                                              AND gstrp = wa_zgdppdt0001-gstrp
                                              AND matnr = wa_zgdppdt0001-matnr
                                              AND aufnr = wa_zgdppdt0001-aufnr
                                              AND charg = wa_zgdppdt0001-charg
                                              AND lgort = wa_zgdppdt0001-lgort.
                      CATCH cx_sy_open_sql_db INTO oref.
                        lv_message = oref->get_text( ).
                    ENDTRY.

                    IF lv_message IS INITIAL.
                      COMMIT WORK AND WAIT.
                    ELSE.
                      ROLLBACK WORK.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

      IF radio3 = 'X'.
        IF i_zgdppdt0001[] IS INITIAL.
          MESSAGE i010(zz) WITH 'No Data'.
          EXIT.
        ENDIF.
        PERFORM f_validate_data21.
        PERFORM print.
      ENDIF.

    WHEN 3.
      SELECT * INTO TABLE gt_warehouse
        FROM t320
        WHERE werks EQ p_werks
          AND lgort EQ p_umlgo.

      CALL SCREEN 900.

    WHEN OTHERS.
      MESSAGE i010(zz) WITH 'No Process'.
      EXIT.
  ENDCASE.

  PERFORM f_free_memory.


*FUNCTION bapi_reservation_delete.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(RESERVATION) TYPE  BAPI2093_RES_KEY-RESERV_NO
*"     VALUE(TESTRUN) TYPE  BAPI2093_TEST OPTIONAL
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL


*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdppe0001f01.

  INCLUDE ztsppp_ex01m01.

  INCLUDE ztsppp_ex01f01.
*------------------common includes for the program---------------------*



*Selection texts
*---------------
*SP_CHK1          CBU Delivery
*SP_CHK2          Trimming Off
*SP_CHK4          Welding Off
*SP_DATE          Month
*SS_WERKS         Plant
