REPORT zf_vatout_print MESSAGE-ID zf NO STANDARD PAGE HEADING
                                     LINE-COUNT 60
                                     LINE-SIZE  253.

INCLUDE zf_vatout_process_top.

* Menu Faktur Opname
SELECTION-SCREEN BEGIN OF BLOCK block9 WITH FRAME TITLE text-090.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(40) text-091 FOR FIELD radio1.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) text-092 FOR FIELD radio2.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) text-093 FOR FIELD radio3.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK block9.

* Print Selection
SELECTION-SCREEN BEGIN OF SCREEN 9001 AS WINDOW TITLE v_title.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_vkorg LIKE tvko-vkorg OBLIGATORY DEFAULT '8020'
                                    MODIF ID xxx,
            p_vkbur LIKE tvbur-vkbur OBLIGATORY.
*SELECT-OPTIONS: s_erdat FOR vbrk-erdat OBLIGATORY,
*                s_fkdat FOR vbrk-fkdat OBLIGATORY,
SELECT-OPTIONS: s_erdat FOR vbrk-erdat,
                s_vbeln FOR vbrk-vbeln,
                s_zuonr FOR vbrk-zuonr,
                s_kunrg FOR vbrk-kunrg,
                s_spdot FOR zsl_hsales-spdot.
SELECTION-SCREEN SKIP.
PARAMETERS : p_vatdn AS CHECKBOX DEFAULT 'X' MODIF ID xxx.
PARAMETERS : p_prev AS CHECKBOX MODIF ID pre.
SELECTION-SCREEN SKIP.
*SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_npwp RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) text-010 FOR FIELD p_npwp.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_exppn AS CHECKBOX.
SELECTION-SCREEN COMMENT 48(20) text-012 FOR FIELD p_exppn.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_nnpwp RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) text-011 FOR FIELD p_nnpwp.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type1 RADIOBUTTON GROUP grp3 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) text-013 FOR FIELD p_type1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type2 RADIOBUTTON GROUP grp3.
SELECTION-SCREEN : COMMENT 5(35) text-014 FOR FIELD p_type2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME.
PARAMETERS: p_npwp1 AS CHECKBOX DEFAULT 'X'." MODIF ID xxx.
SELECTION-SCREEN END OF BLOCK block4.

SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN END OF SCREEN 9001.


* At Selection Screen.
AT SELECTION-SCREEN ON p_vkbur.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD p_vkbur
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH
    'You have no authorization for Sales Office' p_vkbur.
  ENDIF.

* VALIDATE FOR SELECTION
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF radio1 = 'X'.
      IF screen-group1 = 'XXX'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
*    IF p_vkbur = '0201' OR
*       p_vkbur = '0202'.
*      p_type1 = ' '.
*      p_type2 = 'X'.
*    ELSE.
*      p_type1 = 'X'.
*      p_type2 = ' '.
*    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

* INITIALIZATION
INITIALIZATION.
*  s_erdat-sign = 'I'.
*  s_erdat-option = 'BT'.
*  CONCATENATE sy-datum(4) sy-datum+4(2) '01' INTO s_erdat-low.
*  s_erdat-high = sy-datum - 1.
*  APPEND s_erdat.

  v_line = 13.

* Process Selection
START-OF-SELECTION.
  CASE 'X'.
    WHEN radio1.
      v_title = 'Print VAT Out Document ( Batam )'.
      CALL SELECTION-SCREEN 9001.
      IF sy-subrc = 0.
        CLEAR wa_vatnm.
        SELECT SINGLE * INTO wa_vatnm
          FROM zfvatnm WHERE vkorg = p_vkorg AND
                             vkbur = p_vkbur AND
                             vtart = 'SD'.
        i_spopli-selflag = 'X'.
        CONCATENATE wa_vatnm-vatnm 'Jabatan :' wa_vatnm-vattl '/' wa_vatnm-object1
            INTO i_spopli-varoption SEPARATED BY space.
        APPEND i_spopli.
        IF NOT wa_vatnm-vatnm2 IS INITIAL.
          i_spopli-selflag = ' '.
          CONCATENATE wa_vatnm-vatnm2 'Jabatan :' wa_vatnm-vattl2 '/' wa_vatnm-object2
              INTO i_spopli-varoption SEPARATED BY space.
          APPEND i_spopli.
        ENDIF.
        IF NOT wa_vatnm-vatnm3 IS INITIAL.
          i_spopli-selflag = ' '.
          CONCATENATE wa_vatnm-vatnm3 'Jabatan :' wa_vatnm-vattl3 '/' wa_vatnm-object3
              INTO i_spopli-varoption SEPARATED BY space.
          APPEND i_spopli.
        ENDIF.

        CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
          EXPORTING
*           CURSORLINE               = 1
*           MARK_FLAG                = ' '
*           MARK_MAX                 = 1
            start_col                = 20
            start_row                = 5
            textline1                = 'Choose Sign Autorize should'
            textline2                = 'be print .....'
*           TEXTLINE3                = ' '
            titel                    = 'Sign Selection'
*           DISPLAY_ONLY             = ' '
          IMPORTING
            answer                   = v_answer
          TABLES
            t_spopli                 = i_spopli
          EXCEPTIONS
            not_enough_answers       = 1
            too_much_answers         = 2
            too_much_marks           = 3
            OTHERS                   = 4.
*        IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.

        IF v_answer NE 'A'.
          IF p_vatdn = 'X'.
            PERFORM get_data_printdn.
          ELSE.
            PERFORM get_data_print.
          ENDIF.
          PERFORM f_print USING c_smartform_name
                          CHANGING gv_ucomm.

          CHECK gv_ucomm EQ 'PRNT'.

          PERFORM f_write_file.
*          PERFORM print_vatout.
        ENDIF.
      ENDIF.

    WHEN radio2.
*      CALL SELECTION-SCREEN 9002.
      SUBMIT zfr_sp_faktur VIA SELECTION-SCREEN AND RETURN.

    WHEN radio3.
      v_title = 'Reprint VAT Out Document'.
      CALL SELECTION-SCREEN 9001.
      IF sy-subrc = 0.
        CLEAR wa_vatnm.
        SELECT SINGLE * INTO wa_vatnm
          FROM zfvatnm WHERE vkorg = p_vkorg AND
                             vkbur = p_vkbur AND
                             vtart = 'SD'.
        i_spopli-selflag = 'X'.
        CONCATENATE wa_vatnm-vatnm 'Jabatan :' wa_vatnm-vattl '/' wa_vatnm-object1
            INTO i_spopli-varoption SEPARATED BY space.
        APPEND i_spopli.
        IF NOT wa_vatnm-vatnm2 IS INITIAL.
          i_spopli-selflag = ' '.
          CONCATENATE wa_vatnm-vatnm2 'Jabatan :' wa_vatnm-vattl2 '/' wa_vatnm-object2
              INTO i_spopli-varoption SEPARATED BY space.
          APPEND i_spopli.
        ENDIF.
        IF NOT wa_vatnm-vatnm3 IS INITIAL.
          i_spopli-selflag = ' '.
          CONCATENATE wa_vatnm-vatnm3 'Jabatan :' wa_vatnm-vattl3 '/' wa_vatnm-object3
              INTO i_spopli-varoption SEPARATED BY space.
          APPEND i_spopli.
        ENDIF.

        CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
          EXPORTING
*           CURSORLINE               = 1
*           MARK_FLAG                = ' '
*           MARK_MAX                 = 1
            start_col                = 20
            start_row                = 5
            textline1                = 'Choose Sign Autorize should'
            textline2                = 'be print .....'
*           TEXTLINE3                = ' '
            titel                    = 'Sign Selection'
*           DISPLAY_ONLY             = ' '
          IMPORTING
            answer                   = v_answer
          TABLES
            t_spopli                 = i_spopli
          EXCEPTIONS
            not_enough_answers       = 1
            too_much_answers         = 2
            too_much_marks           = 3
            OTHERS                   = 4.
*        IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ENDIF.

        IF v_answer NE 'A'.
          IF p_vatdn = 'X'.
            PERFORM get_data_printdn.
          ELSE.
            PERFORM get_data_print.
          ENDIF.
          PERFORM f_print USING c_smartform_name
                          CHANGING gv_ucomm.

          CHECK gv_ucomm EQ 'PRNT'.

          PERFORM f_write_file.
*          PERFORM print_vatout.
        ENDIF.
      ENDIF.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  get_data_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_print.

  DATA : BEGIN OF lt_konv OCCURS 0,
           knumv LIKE konv-knumv,
           kposn LIKE konv-kposn,
           koaid LIKE konv-koaid,
           kschl LIKE konv-kschl,
           kwert LIKE konv-kwert,
           kbetr LIKE konv-kbetr,
         END OF lt_konv.

  DATA : l_year(4) TYPE n,
         lw_vatgb LIKE i_vatgb.

* Get Flag Live
  SELECT SINGLE live
    INTO v_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel = p_vkbur AND
          b~bukrs = p_vkorg.

* Get Data For Print ---------------------
  IF radio1 = 'X'.
* Get Header Data NPWP
    IF p_npwp = 'X'.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'SD'     AND
              cityc = 'T1'     AND
              flag1 IN ('D','K','G',' ') AND
              fl_cancel = space.

* Get Header Data NONNPWP
    ELSE.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'SD'     AND
              cityc = 'T0'     AND
              flag1 IN ('D','K','G',' ') AND
              fl_cancel = space.
    ENDIF.
  ENDIF.

* Get Data For Reprint ---------------------
  IF radio3 = 'X'.
* Get Header Data NPWP
    IF p_npwp = 'X'.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'SD'     AND
              cityc = 'T1'     AND
              flag1 IN ('V','D','K','G',' ') AND
              fl_cancel = space.

* Get Header Data NONNPWP
    ELSE.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'SD'     AND
              cityc = 'T0'     AND
              flag1 IN ('V','D','K','G',' ') AND
              fl_cancel = space.
    ENDIF.
  ENDIF.

  IF i_zfvato[] IS INITIAL.
    MESSAGE i000(zf) WITH 'No Data'.
    STOP.
  ENDIF.

* Get Customer
  IF radio3 = 'X'.
    SELECT a~kunnr a~adrnr a~stras a~ort01 a~pstlz a~stceg
           b~name_co b~str_suppl1 b~str_suppl2 b~str_suppl3
      INTO CORRESPONDING FIELDS OF TABLE i_cust
      FROM kna1 AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
      FOR ALL ENTRIES IN i_zfvato
      WHERE a~kunnr = i_zfvato-kunrg.
  ENDIF.

* Get Detail Data Legacy
  IF v_live IS INITIAL.
    SELECT b~vbeln posnr matnr fkimg nsp disa disb disc
           disd disdc dise disf b~disvol b~cod
      FROM zsl_hsales AS a JOIN zsl_dsales AS b ON a~vbeln = b~vbeln AND
                                                   a~gjahr = b~gjahr
      INTO CORRESPONDING FIELDS OF TABLE i_zsl_dsales
      FOR ALL ENTRIES IN i_zfvato
      WHERE vkbur = i_zfvato-vkbur      AND
            a~vbtyp = i_zfvato-vbtyp    AND
            stafjk = 'X'                AND
            vkorg = i_zfvato-vkorg      AND
            fkdat = i_zfvato-erdat      AND
            account_no = i_zfvato-vbeln AND
*            a~vbeln = i_zfvato-zuonr    AND
            kunnr = i_zfvato-kunrg      AND
*            spdot = i_zfvato-ihrez.
            fkimg NE 0.

* Get Detail SAP
  ELSE.
    SELECT b~vbeln posnr fkimg vrkme matnr
           arktx b~netwr mwsbp
      FROM vbrk AS a JOIN vbrp AS b ON a~vbeln = b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE i_vbrp
      FOR ALL ENTRIES IN i_zfvato
      WHERE a~vbeln = i_zfvato-vbeln AND
            fkimg NE 0               AND
          ( pstyv NE 'ZT9O' AND pstyv NE 'ZR9O' ).

* Get KONV
    SELECT knumv kposn koaid kschl kwert kbetr
      INTO CORRESPONDING FIELDS OF TABLE lt_konv
      FROM konv
      FOR ALL ENTRIES IN i_zfvato
      WHERE knumv = i_zfvato-knumv AND
            kntyp = space.
  ENDIF.

* Process Detail SAP
  SORT i_vbrp BY vbeln.
  SORT i_zfvato BY vbeln.
  LOOP AT i_zfvato.
    LOOP AT i_vbrp WHERE vbeln = i_zfvato-vbeln.
      LOOP AT lt_konv WHERE knumv = i_zfvato-knumv AND
                            kposn = i_vbrp-posnr.
        IF lt_konv-koaid = 'B'.
          i_vatgb-kbetr = lt_konv-kbetr.
          i_vatgb-kwert = lt_konv-kwert.
        ELSEIF lt_konv-koaid = 'A'.
          IF lt_konv-kschl CP 'ZA*'.
            ADD lt_konv-kwert TO i_vatgb-sdisc.
          ELSEIF lt_konv-kschl CP 'ZB*'.
            ADD lt_konv-kwert TO i_vatgb-sdisc.
          ELSEIF lt_konv-kschl CP 'ZC*'.
            ADD lt_konv-kwert TO i_vatgb-sdisc.
          ELSEIF lt_konv-kschl CP 'ZD*'.
            IF lt_konv-kschl = 'ZD02'.
              ADD lt_konv-kwert TO i_vatgb-cdisc.
            ELSE.
              ADD lt_konv-kwert TO i_vatgb-sdisc.
            ENDIF.
          ELSEIF lt_konv-kschl CP 'ZE*'.
            ADD lt_konv-kwert TO i_vatgb-sdisc.
          ELSEIF lt_konv-kschl CP 'ZF*'.
            ADD lt_konv-kwert TO i_vatgb-sdisc.
          ELSEIF lt_konv-kschl CP 'ZV*'.
            ADD lt_konv-kwert TO i_vatgb-vdisc.
          ENDIF.
        ENDIF.
      ENDLOOP.
      i_vatgb-vbeln = i_zfvato-vbeln.
      i_vatgb-zuonr = i_zfvato-zuonr.
      i_vatgb-matnr = i_vbrp-matnr.
      i_vatgb-arktx = i_vbrp-arktx.
      i_vatgb-vrkme = i_vbrp-vrkme.
      i_vatgb-fkimg = i_vbrp-fkimg.
      i_vatgb-netwr = i_vbrp-netwr.
      i_vatgb-mwsbp = i_vbrp-mwsbp.
* Kalau data sudah ada maka clear NSP agar tidak double
      CLEAR lw_vatgb.
      READ TABLE i_vatgb WITH KEY vbeln = i_zfvato-vbeln
                                  zuonr = i_zfvato-zuonr
                                  matnr = i_vbrp-matnr
                         INTO lw_vatgb.
      IF sy-subrc = 0.
        CLEAR i_vatgb-kbetr.
      ENDIF.
* Collect itab
      COLLECT i_vatgb. CLEAR i_vatgb.
    ENDLOOP.
  ENDLOOP.

* Process Detail Legacy
  SORT i_zsl_dsales BY vbeln.
  SORT i_zfvato BY zuonr.
  LOOP AT i_zfvato.
    LOOP AT i_zsl_dsales WHERE vbeln = i_zfvato-zuonr.
      SELECT SINGLE maktx
        FROM makt
        INTO i_vatgb-arktx
        WHERE matnr = i_zsl_dsales-matnr.
      i_vatgb-vbeln = i_zsl_dsales-vbeln.
      i_vatgb-zuonr = i_zfvato-zuonr.
      i_vatgb-matnr = i_zsl_dsales-matnr.
*      i_vatgb-vrkme = i_zsl_dsales-vrkme.
      i_vatgb-fkimg = i_zsl_dsales-fkimg.
      i_vatgb-kwert = i_zsl_dsales-nsp.
*      i_vatgb-netwr = i_zsl_dsales-netwr.
*      i_vatgb-mwsbp = i_zsl_dsales-mwsbp.
      i_vatgb-kbetr = i_vatgb-kwert / i_vatgb-fkimg.
      i_vatgb-sdisc = i_zsl_dsales-disa + i_zsl_dsales-disb +
                      i_zsl_dsales-disc + i_zsl_dsales-disd +
                      i_zsl_dsales-disdc + i_zsl_dsales-dise +
                      i_zsl_dsales-disf.
      i_vatgb-vdisc = i_zsl_dsales-disvol.
      i_vatgb-cdisc = i_zsl_dsales-cod.
* Kalau data sudah ada maka clear NSP agar tidak double
      CLEAR lw_vatgb.
      READ TABLE i_vatgb WITH KEY vbeln = i_zsl_dsales-vbeln
                                  zuonr = i_zfvato-zuonr
                                  matnr = i_zsl_dsales-matnr
                         INTO lw_vatgb.
      IF sy-subrc = 0.
        CLEAR i_vatgb-kbetr.
      ENDIF.
* Collect itab
      COLLECT i_vatgb. CLEAR i_vatgb.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " get_data_print

*&---------------------------------------------------------------------*
*&      Form  get_data_printDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_printdn.

  DATA : BEGIN OF lt_konv OCCURS 0,
           knumv LIKE konv-knumv,
           kposn LIKE konv-kposn,
           koaid LIKE konv-koaid,
           kschl LIKE konv-kschl,
           kwert LIKE konv-kwert,
           kbetr LIKE konv-kbetr,
         END OF lt_konv.

  DATA : l_year(4) TYPE n,
         lw_vatgb LIKE i_vatgb.

* Get Flag Live
  SELECT SINGLE live
    INTO v_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel = p_vkbur AND
          b~bukrs = p_vkorg.

* Get Data For Print ---------------------
  IF radio1 = 'X'.
* Get Header Data NPWP
    IF p_npwp = 'X'.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'DN'     AND
              cityc = 'T1'     AND
              flag1 IN ('D','K','G',' ') AND
              fl_cancel = space AND
              counter EQ 0.

* Get Header Data NONNPWP
    ELSE.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'DN'     AND
              cityc = 'T0'     AND
              flag1 IN ('D','K','G',' ') AND
              fl_cancel = space AND
              counter EQ 0.
    ENDIF.
  ENDIF.

* Get Data For Reprint ---------------------
  IF radio3 = 'X'.
* Get Header Data NPWP
    IF p_npwp = 'X'.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'DN'     AND
              cityc = 'T1'     AND
              flag1 IN ('V','D','K','G',' ') AND
              fl_cancel = space.

* Get Header Data NONNPWP
    ELSE.
      SELECT *
        FROM zfvato
        INTO CORRESPONDING FIELDS OF TABLE i_zfvato
        WHERE vkorg = p_vkorg  AND
              vkbur = p_vkbur  AND
              vbeln IN s_vbeln AND
              zuonr IN s_zuonr AND
              erdat IN s_erdat AND
              kunrg IN s_kunrg AND
              ihrez IN s_spdot AND
              vtart = 'DN'     AND
              cityc = 'T0'     AND
              flag1 IN ('V','D','K','G',' ') AND
              fl_cancel = space.
    ENDIF.
  ENDIF.

  IF i_zfvato[] IS INITIAL.
    MESSAGE i000(zf) WITH 'No Data'.
    STOP.
  ENDIF.

* Get Customer
  IF radio3 = 'X'.
    SELECT a~kunnr a~adrnr a~stras a~ort01 a~pstlz a~stceg
           b~name_co b~str_suppl1 b~str_suppl2 b~str_suppl3
      INTO CORRESPONDING FIELDS OF TABLE i_cust
      FROM kna1 AS a JOIN adrc AS b ON a~adrnr = b~addrnumber
      FOR ALL ENTRIES IN i_zfvato
      WHERE a~kunnr = i_zfvato-kunrg.
  ENDIF.

* Get Detail
  SELECT mblnr zeile matnr menge meins dmbtr waers
    FROM mseg
    INTO CORRESPONDING FIELDS OF TABLE i_mseg
    FOR ALL ENTRIES IN i_zfvato
    WHERE bukrs = i_zfvato-vkorg      AND
          bwart = '641'               AND
          umwrk = i_zfvato-vkbur      AND
          mjahr = i_zfvato-dueyr      AND
          mblnr = i_zfvato-vbeln.

* Process Detail Legacy
  SORT i_mseg BY mblnr.
  SORT i_zfvato BY vbeln.
  LOOP AT i_zfvato.
    LOOP AT i_mseg WHERE mblnr = i_zfvato-vbeln.
      SELECT SINGLE maktx
        FROM makt
        INTO i_vatgb-arktx
        WHERE matnr = i_mseg-matnr.
      i_vatgb-vbeln = i_mseg-mblnr.
      i_vatgb-zuonr = i_zfvato-zuonr.
      i_vatgb-matnr = i_mseg-matnr.
      i_vatgb-fkimg = i_mseg-menge.
      i_vatgb-kwert = i_mseg-dmbtr.
      i_vatgb-kbetr = i_vatgb-kwert / i_vatgb-fkimg.
* Kalau data sudah ada maka clear NSP agar tidak double
      CLEAR lw_vatgb.
      READ TABLE i_vatgb WITH KEY vbeln = i_mseg-mblnr
                                  zuonr = i_zfvato-zuonr
                                  matnr = i_mseg-matnr
                         INTO lw_vatgb.
      IF sy-subrc = 0.
        CLEAR i_vatgb-kbetr.
      ENDIF.
* Collect itab
      COLLECT i_vatgb. CLEAR i_vatgb.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " get_data_printDN

*&---------------------------------------------------------------------*
*&      Form  print_vatout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_vatout.

  IF p_npwp = 'X'.
    PERFORM f_open_form.
    PERFORM f_write_from_npwp.
    PERFORM f_close_form.
  ELSE.
    PERFORM f_open_form.
    PERFORM f_write_from_nonnpwp.
    PERFORM f_close_form.
  ENDIF.
  IF xresult-tdspoolid NE 0.
    PERFORM f_write_file.
  ENDIF.

ENDFORM.                    " print_vatout

*&---------------------------------------------------------------------*
*&      Form  f_open_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_open_form.

  DATA: ld_form(20).

  CASE 'X'.
    WHEN p_type1.
      ld_form = 'ZF_VATOUT_PTTC'.
    WHEN p_type2.
      ld_form = 'ZF_VATOUT_PTT'.
  ENDCASE.

  CALL FUNCTION 'OPEN_FORM'
       EXPORTING
*         DIALOG  = ' '
*           form    = 'ZF_VATOUT_PTT'
*           form    = 'ZF_VATOUT_PTTC'
           form    = ld_form
*         OPTIONS = VOPTION
       IMPORTING
           RESULT  = vresult
       EXCEPTIONS
           canceled           = 1
           device             = 2
           form               = 3
           OPTIONS            = 4
           unclosed           = 5
           mail_options       = 6
           archive_error      = 7
           OTHERS             = 8.

ENDFORM.                    " f_open_form

*&---------------------------------------------------------------------*
*&      Form  f_write_from_npwp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_from_npwp.

  DATA : l_record TYPE i.

  DESCRIBE TABLE i_zfvato LINES l_record.
  CLEAR: vcount.

  SORT i_zfvato BY vkorg vkbur vatno.
  LOOP AT i_zfvato INTO wa_vat1.

* Change Customer Name for Reprint
    IF radio3 = 'X'.
      READ TABLE i_cust WITH KEY kunnr = wa_vat1-kunrg.
      IF sy-subrc = 0.
        wa_vat1-name_co = i_cust-name_co.
        wa_vat1-str_suppl1 = i_cust-str_suppl1.
        wa_vat1-str_suppl2 = i_cust-str_suppl2.
        wa_vat1-pstlz = i_cust-pstlz.
        wa_vat1-stras = i_cust-str_suppl3.
        wa_vat1-ort01 = i_cust-ort01.
        wa_vat1-stceg = i_cust-stceg.
      ENDIF.
    ENDIF.

    CLEAR : oseq, osubtotal, osubtotal_l, osdisc, ovdisc ,opdisc,
            ototal, vcount_dtl, vtot_value, otot_value, otot_disc,
            otax_base, otax_amt, ocdisc.
    ADD 1 TO vcount.
    ADD 1 TO wa_vat1-counter.

    odudat = wa_vat1-dudat.

    IF odudat GE '20070409' AND p_npwp1 IS INITIAL.
      onpwpbaru = 'Sejak 9 April 2007 NPWP Baru : 01.301.808.0-062.000'.
    ELSE.
      CLEAR onpwpbaru.
    ENDIF.

    READ TABLE i_spopli WITH KEY selflag = 'X'.
    IF sy-subrc = 0.
      CASE sy-tabix.
        WHEN 1.
          osign_name = wa_vatnm-vatnm.
          osign_title = wa_vatnm-vattl.
          oobject = wa_vatnm-object1.
        WHEN 2.
          osign_name = wa_vatnm-vatnm2.
          osign_title = wa_vatnm-vattl2.
          oobject = wa_vatnm-object2.
        WHEN 3.
          osign_name = wa_vatnm-vatnm3.
          osign_title = wa_vatnm-vattl3.
          oobject = wa_vatnm-object3.
      ENDCASE.
    ENDIF.
*    CASE 'X'.
*      WHEN p_sign1.
*        osign_name = wa_vatnm-vatnm.
*        osign_title = wa_vatnm-vattl.
*      WHEN p_sign2.
*        osign_name = wa_vatnm-vatnm2.
*        osign_title = wa_vatnm-vattl2.
*      WHEN p_sign3.
*        osign_name = wa_vatnm-vatnm3.
*        osign_title = wa_vatnm-vattl3.
*    ENDCASE.

    IF radio1 = 'X'.
      wa_vat1-vatdt = sy-datum.
      wa_vat1-vattm = sy-uzeit.
      wa_vat1-vatus = sy-uname.
      wa_vat1-flag1 = 'V'.
    ELSE.
      wa_vat1-repdt = sy-datum.
      wa_vat1-reptm = sy-uzeit.
      wa_vat1-repus = sy-uname.
    ENDIF.

    PERFORM f_print_header_npwp.
    PERFORM f_space.
    IF p_vatdn = 'X'.
      LOOP AT i_vatgb WHERE zuonr = wa_vat1-zuonr AND
                            fkimg NE 0.
        PERFORM f_print_detail.
      ENDLOOP.
    ELSE.
      IF v_live EQ space.
        LOOP AT i_vatgb WHERE vbeln = wa_vat1-zuonr AND
                              fkimg NE 0.
          PERFORM f_print_detail.
        ENDLOOP.
      ELSE.
        LOOP AT i_vatgb WHERE vbeln = wa_vat1-vbeln AND
                              fkimg NE 0.
          PERFORM f_print_detail.
        ENDLOOP.
      ENDIF.
    ENDIF.
    PERFORM f_print_summary_npwp.
    PERFORM f_print_sign.
    PERFORM f_print_footer_npwp.
    IF vcount NE l_record.
      PERFORM f_skip.
    ENDIF.
    CLEAR wa_vat1-tkwert.
    wa_vat1-tkwert = ototal / 100.

    MODIFY i_zfvato FROM wa_vat1.
  ENDLOOP.

ENDFORM.                    " f_write_from_npwp

*&---------------------------------------------------------------------*
*&      Form  f_close_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_form.

  CALL FUNCTION 'CLOSE_FORM'
    IMPORTING
      RESULT   = xresult
    EXCEPTIONS
      unopened = 1.

ENDFORM.                    " f_close_form

*&---------------------------------------------------------------------*
*&      Form  f_write_from_nonnpwp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_from_nonnpwp.
  DATA : l_record TYPE i.

  DESCRIBE TABLE i_zfvato LINES l_record.
  CLEAR: vcount.

  SORT i_zfvato BY vkorg vkbur zuonr.
  LOOP AT i_zfvato INTO wa_vat1.

* Change Customer Name for Reprint
    IF radio3 = 'X'.
      READ TABLE i_cust WITH KEY kunnr = wa_vat1-kunrg.
      IF sy-subrc = 0.
        wa_vat1-name_co = i_cust-name_co.
        wa_vat1-str_suppl1 = i_cust-str_suppl1.
        wa_vat1-str_suppl2 = i_cust-str_suppl2.
        wa_vat1-pstlz = i_cust-pstlz.
        wa_vat1-stras = i_cust-str_suppl3.
        wa_vat1-ort01 = i_cust-ort01.
        wa_vat1-stceg = i_cust-stceg.
      ENDIF.
    ENDIF.

    CLEAR : oseq, osubtotal, osubtotal_l, osdisc, ovdisc ,opdisc, ototal,
                vcount_dtl, vtot_value, otot_value, otot_disc, otax_base,
                                                        otax_amt, ocdisc.
    ADD 1 TO vcount.
    ADD 1 TO wa_vat1-counter.

    odudat = wa_vat1-dudat.
*    osign_name = x_vatnm.
*    osign_title = x_vattl.

    IF odudat GE '20070409' AND p_npwp1 IS INITIAL.
      onpwpbaru1 = 'Sejak 9 April 2007 NPWP Baru : 01.301.808.0-062.000'.
    ELSE.
      CLEAR onpwpbaru1.
    ENDIF.

    READ TABLE i_spopli WITH KEY selflag = 'X'.
    IF sy-subrc = 0.
      CASE sy-tabix.
        WHEN 1.
          osign_name = wa_vatnm-vatnm.
          osign_title = wa_vatnm-vattl.
          oobject = wa_vatnm-object1.
        WHEN 2.
          osign_name = wa_vatnm-vatnm2.
          osign_title = wa_vatnm-vattl2.
          oobject = wa_vatnm-object2.
        WHEN 3.
          osign_name = wa_vatnm-vatnm3.
          osign_title = wa_vatnm-vattl3.
          oobject = wa_vatnm-object3.
      ENDCASE.
    ENDIF.
*    CASE 'X'.
*      WHEN p_sign1.
*        osign_name = wa_vatnm-vatnm.
*        osign_title = wa_vatnm-vattl.
*      WHEN p_sign2.
*        osign_name = wa_vatnm-vatnm2.
*        osign_title = wa_vatnm-vattl2.
*      WHEN p_sign3.
*        osign_name = wa_vatnm-vatnm3.
*        osign_title = wa_vatnm-vattl3.
*    ENDCASE.

    IF radio1 = 'X'.
      wa_vat1-vatdt = sy-datum.
      wa_vat1-vattm = sy-uzeit.
      wa_vat1-vatus = sy-uname.
      wa_vat1-flag1 = 'V'.
    ELSE.
      wa_vat1-repdt = sy-datum.
      wa_vat1-reptm = sy-uzeit.
      wa_vat1-repus = sy-uname.
    ENDIF.

    PERFORM f_print_header_nonnpwp.
    IF v_live EQ space.
      LOOP AT i_vatgb WHERE vbeln = wa_vat1-zuonr AND
                            fkimg NE 0.
        PERFORM f_print_detail.
      ENDLOOP.
    ELSE.
      LOOP AT i_vatgb WHERE vbeln = wa_vat1-vbeln AND
                            fkimg NE 0.
        PERFORM f_print_detail.
      ENDLOOP.
    ENDIF.
    PERFORM f_print_summary_nonnpwp.
    PERFORM f_print_sign.
    PERFORM f_print_footer_nonnpwp.
    IF vcount NE l_record.
      PERFORM f_skip.
    ENDIF.
    CLEAR wa_vat1-tkwert.
    wa_vat1-tkwert = ototal / 100.

    MODIFY i_zfvato FROM wa_vat1.
  ENDLOOP.

ENDFORM.                    " f_write_from_nonnpwp

*&---------------------------------------------------------------------*
*&      Form  f_write_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_file.
  MODIFY zfvato FROM TABLE i_zfvato.
ENDFORM.                    " f_write_file

*&---------------------------------------------------------------------*
*&      Form  f_print_header_npwp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_header_npwp.

  DATA: ld_stkza LIKE kna1-stkza.

  CLEAR: ogform,onppkp.
  SELECT SINGLE gform stkza FROM kna1
    INTO (ogform,ld_stkza)
    WHERE kunnr = wa_vat1-kunrg.    " AND
*          gform = 'A2'.

  oname1 = wa_vat1-name_co.
  oname2 = wa_vat1-str_suppl1.
  oname3 = wa_vat1-str_suppl2.
  opstlz = wa_vat1-pstlz.
  ostras = wa_vat1-stras+0(30).
  oort01 = wa_vat1-ort01.
  ostceg = wa_vat1-stceg.

  IF wa_vat1-dudat GE '20070101'.
    ovatpr = wa_vat1-vatpr.
    IF ld_stkza IS INITIAL.
      onppkp = 'N.P.P.K.P :'.
    ELSE.
      CONCATENATE 'N.P.P.K.P :' ostceg INTO onppkp SEPARATED BY space.
    ENDIF.
  ELSE.
    CONCATENATE wa_vat1-vatpr+0(10) wa_vat1-vatpr+11(7) INTO ovatpr.
  ENDIF.

  IF NOT ogform = 'A2'.
    CLEAR ogform.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'SERIAL'
    EXCEPTIONS
      OTHERS  = 1.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'NPWP'
    EXCEPTIONS
      OTHERS = 1.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'INFO'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_print_header_npwp

*&---------------------------------------------------------------------*
*&      Form  f_space
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_space.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SPACE'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_space

*&---------------------------------------------------------------------*
*&      Form  f_print_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_detail.

  IF vcount_dtl GE v_line.
    vcount_dtl = 0.
    PERFORM f_space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SUBTOTAL'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
    PERFORM f_print_sign.
    IF p_npwp = 'X'.
      PERFORM f_print_footer_npwp.
    ELSEIF p_nnpwp = 'X'.
      PERFORM f_print_footer_nonnpwp.
    ENDIF.
    PERFORM f_skip.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SUBTOTAL_L'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  ADD 1 TO vcount_dtl.
  ADD 1 TO oseq.
  omatnr = i_vatgb-matnr.
  oarktx = i_vatgb-arktx.
  ofkimg = i_vatgb-fkimg.
  IF p_exppn = 'X'.
    okbetr = ( i_vatgb-kbetr * 100 ) / ( 110 / 100 ).
    okwert = ( i_vatgb-kwert * 100 ) / ( 110 / 100 ).
  ELSE.
    okbetr = i_vatgb-kbetr * 100.
    okwert = i_vatgb-kwert * 100.
  ENDIF.
  ADD i_vatgb-sdisc TO osdisc.
  ADD i_vatgb-vdisc TO ovdisc.
  ADD i_vatgb-cdisc TO ocdisc.
  ADD okwert TO osubtotal.
  ADD okwert TO osubtotal_l.
  ADD okwert TO ototal.
  ADD okwert TO vtot_value.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_LINE'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_print_detail

*&---------------------------------------------------------------------*
*&      Form  f_print_summary_npwp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_summary_npwp.

  DATA : l_vdisc TYPE tpdisc.

  CLEAR: otot_disc, otax_base, otax_amt, otot_gros, l_vdisc.
  otot_value = vtot_value.

  IF p_exppn = 'X'.
    osdisc = ( osdisc * 100 ) / ( 110 / 100 ).
    ovdisc = ( ovdisc * 100 ) / ( 110 / 100 ).
    ocdisc = ( ocdisc * 100 ) / ( 110 / 100 ).
  ELSE.
    osdisc = osdisc * 100.
    ovdisc = ovdisc * 100.
    ocdisc = ocdisc * 100.
  ENDIF.

  IF v_live = 'X'.
    ototal = ototal + osdisc + ovdisc + ocdisc.
    otax_base = wa_vat1-netwr * 100.
  ELSE.
    ototal = wa_vat1-netwr * 100.
    otax_base = ( wa_vat1-netwr * 100 ) / ( 110 / 100 ).
    l_vdisc = ( ovdisc * 100 ) / ototal.
    IF l_vdisc < 1.
      ADD ovdisc TO osdisc.
      CLEAR ovdisc.
    ENDIF.
  ENDIF.

  otot_disc = osdisc + ovdisc + ocdisc.
  otax_amt = wa_vat1-mwsbk * 100.
  IF otot_disc LT 0.
    otot_disc = otot_disc * -1.
  ENDIF.

  IF osdisc NE 0.
    IF osdisc LT 0.
      osdisc = osdisc * -1.
    ENDIF.
    otot_gros = otot_value.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'GROS_TOTAL'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SDISC'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  IF ( ovdisc NE 0 AND ototal NE 0 ) OR
     ( ocdisc NE 0 AND ototal NE 0 ).
    IF ovdisc LT 0.
      ovdisc = ovdisc * -1.
    ENDIF.
    IF ocdisc LT 0.
      ocdisc = ocdisc * -1.
    ENDIF.
    CLEAR vpdisc.
    vpdisc = ( ovdisc * 100 ) / ototal.
    opdisc = vpdisc.
    otot_gros = otot_value - osdisc.
    IF ocdisc NE 0.
      ovdisc = ovdisc + ocdisc.
      CLEAR opdisc.
    ENDIF.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'GROS_TOTAL'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'VDISC'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'TOTAL'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'SUM'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_print_summary_npwp

*&---------------------------------------------------------------------*
*&      Form  f_print_sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_sign.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'SIGN'
    EXCEPTIONS
      OTHERS = 1.

  IF p_type1 = 'X'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        window = 'SIGN1'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  IF p_npwp = 'X'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'NPWP'
        window  = 'SUM_TEXT'
      EXCEPTIONS
        OTHERS  = 1.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'NONNPWP'
        window  = 'GRAPH1'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

ENDFORM.                    " f_print_sign

*&---------------------------------------------------------------------*
*&      Form  f_print_footer_npwp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_footer_npwp.

*  CLEAR ogform.
*  SELECT SINGLE gform FROM kna1 INTO ogform
*    WHERE kunnr = wa_vat1-kunrg AND
*          gform = 'A2'.

  odotyp = wa_vat1-fkart+3(1).
  obln = wa_vat1-fkdat+4(2).
  IF wa_vat1-zuonr_ref IS INITIAL.
    CLEAR ozuonr_ref.
  ELSE.
    CONCATENATE 'Ref:' wa_vat1-zuonr_ref INTO ozuonr_ref SEPARATED BY space.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NPWP'
      window  = 'FOOTER'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_print_footer_npwp

*&---------------------------------------------------------------------*
*&      Form  f_skip
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_skip.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SKIP'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " f_skip

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FOOTER_NONNPWP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_footer_nonnpwp.

  CLEAR ogform.
  SELECT SINGLE gform FROM kna1 INTO ogform
    WHERE kunnr = wa_vat1-kunrg AND
          gform = 'A2'.

  odotyp = wa_vat1-fkart+3(1).
  obln = wa_vat1-fkdat+4(2).
  IF wa_vat1-zuonr_ref IS INITIAL.
    CLEAR ozuonr_ref.
  ELSE.
    CONCATENATE 'Ref:' wa_vat1-zuonr_ref INTO ozuonr_ref SEPARATED BY space.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NONNPWP'
      window  = 'FOOTER'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " F_PRINT_FOOTER_NONNPWP

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_HEADER_NONNPWP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_header_nonnpwp.

  ozuonr = wa_vat1-zuonr.
  ovkorg = wa_vat1-vkorg.
  oname1 = wa_vat1-name_co.
  oname2 = wa_vat1-str_suppl1.
  oname3 = wa_vat1-str_suppl2.
  opstlz = wa_vat1-pstlz.
  ostras = wa_vat1-stras+0(30).
  oort01 = wa_vat1-ort01.
  ostceg = wa_vat1-stceg.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NONNPWP'
      window  = 'SERIAL'
    EXCEPTIONS
      OTHERS  = 1.
*  CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            window = 'NPWP1'
*       EXCEPTIONS
*            OTHERS = 1.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NONNPWP'
      window  = 'INFO'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " F_PRINT_HEADER_NONNPWP

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SUMMARY_NONNPWP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_summary_nonnpwp.

  DATA : l_vdisc TYPE tpdisc.

  CLEAR: otot_disc, otax_base, otax_amt, l_vdisc.
  otot_value = vtot_value.

  IF p_exppn = 'X'.
    osdisc = ( osdisc * 100 ) / ( 110 / 100 ).
    ovdisc = ( ovdisc * 100 ) / ( 110 / 100 ).
    ocdisc = ( ocdisc * 100 ) / ( 110 / 100 ).
  ELSE.
    osdisc = osdisc * 100.
    ovdisc = ovdisc * 100.
    ocdisc = ocdisc * 100.
  ENDIF.

  IF v_live = 'X'.
    ototal = ototal + osdisc + ovdisc + ocdisc.
    otax_base = wa_vat1-netwr * 100.
  ELSE.
    ototal = wa_vat1-netwr * 100.
    otax_base = ( wa_vat1-netwr * 100 ) / ( 110 / 100 ).
    l_vdisc = ( ovdisc * 100 ) / ototal.
    IF l_vdisc < 1.
      ADD ovdisc TO osdisc.
      CLEAR ovdisc.
    ENDIF.
  ENDIF.

  otot_disc = osdisc + ovdisc + ocdisc.
  otax_amt = wa_vat1-mwsbk * 100.
  IF otot_disc LT 0.
    otot_disc = otot_disc * -1.
  ENDIF.

  IF osdisc NE 0.
    IF osdisc LT 0.
      osdisc = osdisc * -1.
    ENDIF.
    otot_gros = otot_value.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'GROS_TOTAL'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SDISC'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  IF ( ovdisc NE 0 AND ototal NE 0 ) OR
     ( ocdisc NE 0 AND ototal NE 0 ).
    IF ovdisc LT 0.
      ovdisc = ovdisc * -1.
    ENDIF.
    IF ocdisc LT 0.
      ocdisc = ocdisc * -1.
    ENDIF.
    CLEAR vpdisc.
    vpdisc = ( ovdisc * 100 ) / ototal.
    opdisc = vpdisc.
    otot_gros = otot_value - osdisc.
    IF ocdisc NE 0.
      ovdisc = ovdisc + ocdisc.
      CLEAR opdisc.
    ENDIF.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'GROS_TOTAL'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'VDISC'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'TOTAL'
      window  = 'MAIN'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'NONNPWP'
      window  = 'SUM'
    EXCEPTIONS
      OTHERS  = 1.

ENDFORM.                    " F_PRINT_SUMMARY_NONNPWP

*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
FORM f_print  USING    p_formname TYPE tdsfname
              CHANGING fc_ucomm.

  DATA:
    l_funcname          TYPE tdsfname,
    l_total_pages       TYPE tdsffpage,
    lwa_control_option  TYPE ssfctrlop,
    lwa_output_option   TYPE ssfcompop,
    lwa_doc_info        TYPE ssfcrespd,
    lwa_output_info     TYPE ssfcrescl.

  DATA : lv_tax   TYPE int4.

* Determine Smartform function module name
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_formname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
*   Message has been maintained inside the function module
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT i_zfvato INTO wa_vat1.

    CLEAR gs_total.

    PERFORM f_header CHANGING gs_header.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    IF p_prev IS INITIAL.
      lwa_output_option-tdnoprev    = 'X'.
    ELSE.
      lwa_output_option-tdnoprint   = 'X'.
    ENDIF.

    lv_tax  = ( 110 / 100 ).

    ADD 1 TO wa_vat1-counter.

    PERFORM f_detail TABLES gt_item
                     USING wa_vat1 lv_tax.

    MODIFY i_zfvato FROM wa_vat1 TRANSPORTING counter.

*    lwa_output_option-tdnoprint = 'X'.

    CALL FUNCTION l_funcname
      EXPORTING
        control_parameters = lwa_control_option
        output_options     = lwa_output_option
        user_settings      = 'X'
        sf_header          = gs_header
        sf_total           = gs_total
        wa_vat1            = wa_vat1
        ovatpr             = ovatpr
        odotyp             = odotyp
        ogform             = ogform
        odudat             = odudat
        osign_name         = osign_name
        osign_title        = osign_title
      TABLES
        gt_detail          = gt_item
        gt_subtl           = gt_subtl
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    lwa_control_option-no_open = 'X'.
  ENDLOOP.

  fc_ucomm  = sy-ucomm.
ENDFORM.                    " F_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  CHANGING fs_header STRUCTURE zgdkomerx.
  CLEAR fs_header.

  CLEAR : ovatpr, odotyp, ogform.

  ovatpr = wa_vat1-vatpr.
  odotyp = wa_vat1-fkart+3(1).

  SELECT SINGLE gform FROM kna1 INTO ogform
    WHERE kunnr EQ wa_vat1-kunrg.

  IF ogform NE 'A2'.
    CLEAR ogform.
  ENDIF.

  odudat  = wa_vat1-dudat.

  READ TABLE i_spopli WITH KEY selflag = 'X'.
  IF sy-subrc = 0.
    CASE sy-tabix.
      WHEN 1.
        osign_name  = wa_vatnm-vatnm.
        osign_title = wa_vatnm-vattl.
        oobject     = wa_vatnm-object1.
      WHEN 2.
        osign_name  = wa_vatnm-vatnm2.
        osign_title = wa_vatnm-vattl2.
        oobject     = wa_vatnm-object2.
      WHEN 3.
        osign_name  = wa_vatnm-vatnm3.
        osign_title = wa_vatnm-vattl3.
        oobject     = wa_vatnm-object3.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL
*&---------------------------------------------------------------------*
FORM f_detail  TABLES   ft_item STRUCTURE zgdkomerx
               USING    fwa_vat1 STRUCTURE zfvato
                        fu_tax.

  DATA : lv_linenum   TYPE num03,
         lv_page      TYPE num03,
         lv_subtl     TYPE kwert,
         lv_total     TYPE kwert,
         lv_mod       TYPE num03,
         lv_tax       TYPE mwsbp.

  CLEAR : ft_item, ft_item[], wa_item, lv_linenum.

  IF p_vatdn = 'X'.
    LOOP AT i_vatgb WHERE zuonr = wa_vat1-zuonr AND
                          fkimg NE 0.
      ADD 1 TO lv_linenum.
      wa_item-linenum = lv_linenum.
      wa_item-matnr   = i_vatgb-matnr.
      wa_item-arktx   = i_vatgb-arktx.
      WRITE i_vatgb-fkimg TO wa_item-qty DECIMALS 2.
      i_vatgb-kbetr = i_vatgb-kbetr / fu_tax.
      WRITE i_vatgb-kbetr TO wa_item-prcpiece CURRENCY 'IDR'.
      i_vatgb-kwert = i_vatgb-kwert / fu_tax.
      WRITE i_vatgb-kwert TO wa_item-harga_rp CURRENCY 'IDR'.
      ADD i_vatgb-kwert TO lv_total.
      ADD i_vatgb-kwert TO lv_subtl.
      APPEND wa_item TO ft_item.

      lv_mod  = lv_linenum MOD 20.
      IF lv_mod IS INITIAL.
        ADD 1 TO lv_page.
        wa_subtl-linenum = lv_page.
        WRITE lv_subtl TO wa_subtl-harga_rp CURRENCY 'IDR'.
        APPEND wa_subtl TO gt_subtl.
        CLEAR lv_subtl.
      ENDIF.

      CLEAR wa_item.
    ENDLOOP.
  ELSE.
    IF v_live EQ space.
      LOOP AT i_vatgb WHERE vbeln = wa_vat1-zuonr AND
                            fkimg NE 0.
        ADD 1 TO lv_linenum.
        wa_item-linenum = lv_linenum.
        wa_item-matnr   = i_vatgb-matnr.
        wa_item-arktx   = i_vatgb-arktx.
        WRITE i_vatgb-fkimg TO wa_item-qty DECIMALS 2.
        i_vatgb-kbetr = i_vatgb-kbetr / fu_tax.
        WRITE i_vatgb-kbetr TO wa_item-prcpiece CURRENCY 'IDR'.
        i_vatgb-kwert = i_vatgb-kwert / fu_tax.
        WRITE i_vatgb-kwert TO wa_item-harga_rp CURRENCY 'IDR'.
        ADD i_vatgb-kwert TO lv_total.
        ADD i_vatgb-kwert TO lv_subtl.
        APPEND wa_item TO ft_item.

        lv_mod  = lv_linenum MOD 20.
        IF lv_mod IS INITIAL.
          ADD 1 TO lv_page.
          wa_subtl-linenum = lv_page.
          WRITE lv_subtl TO wa_subtl-harga_rp CURRENCY 'IDR'.
          APPEND wa_subtl TO gt_subtl.
          CLEAR lv_subtl.
        ENDIF.

        CLEAR wa_item.
      ENDLOOP.
    ELSE.
      LOOP AT i_vatgb WHERE vbeln = wa_vat1-vbeln AND
                            fkimg NE 0.
        ADD 1 TO lv_linenum.
        wa_item-linenum = lv_linenum.
        wa_item-matnr   = i_vatgb-matnr.
        wa_item-arktx   = i_vatgb-arktx.
        WRITE i_vatgb-fkimg TO wa_item-qty DECIMALS 2.
        i_vatgb-kbetr = i_vatgb-kbetr / fu_tax.
        WRITE i_vatgb-kbetr TO wa_item-prcpiece CURRENCY 'IDR'.
        i_vatgb-kwert = i_vatgb-kwert / fu_tax.
        WRITE i_vatgb-kwert TO wa_item-harga_rp CURRENCY 'IDR'.
        ADD i_vatgb-kwert TO lv_total.
        ADD i_vatgb-kwert TO lv_subtl.
        APPEND wa_item TO ft_item.

        lv_mod  = lv_linenum MOD 20.
        IF lv_mod IS INITIAL.
          ADD 1 TO lv_page.
          wa_subtl-linenum = lv_page.
          WRITE lv_subtl TO wa_subtl-harga_rp CURRENCY 'IDR'.
          APPEND wa_subtl TO gt_subtl.
          CLEAR lv_subtl.
        ENDIF.

        CLEAR wa_item.
      ENDLOOP.
    ENDIF.
  ENDIF.

  WRITE lv_total TO gs_total-itamtlast CURRENCY 'IDR'.
  WRITE fwa_vat1-mwsbk TO gs_total-dpplast CURRENCY 'IDR'.
ENDFORM.                    " F_DETAIL
