REPORT zf_vatout_process MESSAGE-ID zf NO STANDARD PAGE HEADING
                                       LINE-COUNT 60
                                       LINE-SIZE  263.

INCLUDE zabp_alv_common.

INCLUDE zf_vatout_process_top.

* Menu Faktur Opname
SELECTION-SCREEN BEGIN OF BLOCK block9 WITH FRAME TITLE TEXT-090.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(40) TEXT-091 FOR FIELD radio1.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-092 FOR FIELD radio2.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-093 FOR FIELD radio3.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-097 FOR FIELD radio4.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-089 FOR FIELD radio5.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-088 FOR FIELD radio6.
SELECTION-SCREEN : END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: radio7 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN COMMENT 5(58) text-087 FOR FIELD radio7.
*SELECTION-SCREEN : END OF LINE.
PARAMETERS: radio8 RADIOBUTTON GROUP grp1.
PARAMETERS: radio9 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK block9.

* Process Selection
SELECTION-SCREEN BEGIN OF SCREEN 9001 AS WINDOW TITLE TEXT-091.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_vkorg LIKE tvko-vkorg OBLIGATORY DEFAULT '8020'
                                    MODIF ID xxx,
            p_vkbur LIKE tvbur-vkbur OBLIGATORY MEMORY ID pvk
                                    MODIF ID 001,
            p_vatbr LIKE zplbc-vatbr OBLIGATORY DEFAULT '000'
                                    MODIF ID xxx,
            p_vatyr LIKE zfvatnr-gjahr OBLIGATORY MODIF ID 003,
            p_dudat LIKE zfvato-dudat NO-DISPLAY.
SELECT-OPTIONS: s_vkbur FOR zsl_hsales-vkbur OBLIGATORY MEMORY ID svk
                                    MODIF ID 002,
                s_fkdat FOR vbrk-fkdat OBLIGATORY MODIF ID 002,
                s_erdat FOR vbrk-erdat MODIF ID 002,
                s_vbeln FOR vbrk-vbeln MODIF ID 002,
                s_zuonr FOR vbrk-zuonr MODIF ID 002,
                s_kunrg FOR vbrk-kunrg MODIF ID 002,
                s_spdot FOR zsl_hsales-spdot MODIF ID 002,
                s_dudat FOR zfvato-dudat OBLIGATORY MODIF ID 002.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_proc RADIOBUTTON GROUP grp2 DEFAULT 'X'
                                           USER-COMMAND grp1.
SELECTION-SCREEN : COMMENT 5(30) TEXT-003 FOR FIELD p_proc.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_prev AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 48(20) TEXT-006 FOR FIELD p_prev.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 4.
PARAMETERS : p_bahan AS CHECKBOX.
SELECTION-SCREEN COMMENT 48(40) TEXT-007 FOR FIELD p_bahan.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_mnumb RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(30) TEXT-004 FOR FIELD p_mnumb.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_msign RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(35) TEXT-005 FOR FIELD p_msign.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block8 WITH FRAME TITLE TEXT-094.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_new RADIOBUTTON GROUP grp3 DEFAULT 'X' MODIF ID 004
                                         USER-COMMAND grp1.
SELECTION-SCREEN COMMENT 5(40) TEXT-095 FOR FIELD p_new MODIF ID 004.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_old RADIOBUTTON GROUP grp3 MODIF ID 004.
SELECTION-SCREEN COMMENT 5(40) TEXT-096 FOR FIELD p_old MODIF ID 004.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK block8.

SELECTION-SCREEN END OF SCREEN 9001.

* Download Selection
SELECTION-SCREEN BEGIN OF SCREEN 9003 AS WINDOW TITLE TEXT-093.
SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_vkorg2    LIKE tvko-vkorg OBLIGATORY DEFAULT '8020'
                                     MODIF ID xxx,
            p_vkbur2    LIKE tvbur-vkbur OBLIGATORY MEMORY ID vkb,
            p_year      LIKE zfvato-dueyr OBLIGATORY DEFAULT sy-datum(4),
*            p_month LIKE zfvato-duemm DEFAULT sy-datum+4(2),
            p_nokir(10) OBLIGATORY MEMORY ID nok.
SELECTION-SCREEN SKIP.
PARAMETERS p_path(52) DEFAULT '\\tdsdev01\interface\faktur\'.
SELECTION-SCREEN END OF BLOCK block3.
SELECTION-SCREEN END OF SCREEN 9003.

* Maintenance table ZFVATTOP
SELECTION-SCREEN BEGIN OF SCREEN 9010 AS WINDOW TITLE TEXT-088.
PARAMETERS: pv_vkorg LIKE zfvattop-vkorg OBLIGATORY DEFAULT '8020'
                                         MODIF ID xxx,
            pv_kdgrp LIKE zfvattop-kdgrp DEFAULT '03'.
SELECTION-SCREEN END OF SCREEN 9010.

* Update Selection
SELECTION-SCREEN BEGIN OF SCREEN 9004 AS WINDOW TITLE TEXT-086.
SELECTION-SCREEN BEGIN OF BLOCK upload WITH FRAME TITLE TEXT-001.
PARAMETERS pa_flnm1   TYPE localfile MODIF ID fl1.
SELECTION-SCREEN END OF BLOCK upload.
SELECTION-SCREEN BEGIN OF BLOCK format WITH FRAME TITLE TEXT-084.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 5(79) TEXT-085.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 5(79) TEXT-083.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK format.
SELECTION-SCREEN END OF SCREEN 9004.

* At Selection Screen
AT SELECTION-SCREEN ON p_vkbur2.
  SELECT SINGLE b~live
    INTO v_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel = p_vkbur2 AND
          b~bukrs = p_vkorg2.
  IF NOT v_live IS INITIAL.
    MESSAGE e000(zf) WITH 'For Legacy Branch Only'.
  ENDIF.

* VALIDATE FOR SELECTION
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'XXX'.
      screen-input = '0'.
    ENDIF.
    IF p_proc = 'X'.
      IF screen-group1 = '001' OR
         screen-group1 = '003' OR
         screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF p_mnumb = 'X'.
      IF p_new = 'X'.
        IF screen-group1 = '004'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = '002'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = '001'.
          screen-active = '0'.
        ENDIF.
      ELSE.
        p_vkbur = '0200'.
        IF screen-group1 = '003'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = '002'.
          screen-active = '0'.
        ENDIF.
        IF screen-group1 = '001'.
          screen-input = '0'.
        ENDIF.
      ENDIF.
    ENDIF.
    IF p_msign = 'X'.
      IF screen-group1 = '002' OR
         screen-group1 = '003' OR
         screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_flnm1.
  PERFORM f_filename_f4 CHANGING pa_flnm1.

* INITIALIZATION
INITIALIZATION.
  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  IF sy-subrc EQ 0.
    p_vkorg   = lv_parva.
    pv_vkorg  = lv_parva.
    p_vkorg2  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    p_vkbur   = lv_parva.
    p_vkbur2  = lv_parva.
  ENDIF.

*  s_erdat-sign = 'I'.
*  s_erdat-option = 'BT'.
*  s_erdat-high = sy-datum - 1.
*  IF s_erdat-high+4(2) = sy-datum+4(2).
*    CONCATENATE sy-datum(4) sy-datum+4(2) '01' INTO s_erdat-low.
*  ELSE.
*    CONCATENATE sy-datum(4) s_erdat-high+4(2) '01' INTO s_erdat-low.
*  ENDIF.
*  APPEND s_erdat.

* Process Selection
START-OF-SELECTION.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  PERFORM f_billing_type USING : 'YCS1', 'YCS3', 'YCS4',
                                 'YCS5', 'YCS9', 'ZCS1',
                                 'ZCS2', 'ZCS4', 'ZCS7',
                                 'ZCS9', 'ZI03', 'ZIGS'.

  CASE 'X'.
* VAT Out Process

    WHEN radio1.
*      SELECT SINGLE *
*        FROM zproject
*        INTO wa_project
*        WHERE name  EQ 'EFAKTUR'
*          AND datab GT sy-datum.
*      IF sy-subrc EQ 0.
      CALL SELECTION-SCREEN 9001.
      IF sy-subrc = 0.
        PERFORM cek_lock.
        PERFORM f_get_flag_zproject.  "For project name PAJAK2013
        CASE 'X'.
          WHEN p_proc.
            PERFORM process_vat.
            PERFORM f_modify_itab_main.   "Untuk customer kimia farma
            PERFORM write_table.
          WHEN p_mnumb.
            PERFORM main_number.
          WHEN p_msign.
            PERFORM main_sign.
        ENDCASE.
      ENDIF.
*      ELSE.
*        MESSAGE s000(zab) WITH 'Harap menggunakan TCode ZF_EFAKTUR'.
*      ENDIF.

* SPF Report
    WHEN radio2.
*      CALL SELECTION-SCREEN 9002.
      SUBMIT zfr_sp_faktur VIA SELECTION-SCREEN AND RETURN.

* VAT Out Download
    WHEN radio3.
      CALL SELECTION-SCREEN 9003.
      IF sy-subrc = 0.
        PERFORM process_download.
        PERFORM download_file.
      ENDIF.

* SSP Process
    WHEN radio4.
      SUBMIT zf_ssp_process VIA SELECTION-SCREEN AND RETURN.

* VAT Out Correction
    WHEN radio5.
      SUBMIT zf_vatout_correction VIA SELECTION-SCREEN AND RETURN.

* Maintenace table ZFVATTOP
    WHEN radio6.
      CALL SELECTION-SCREEN 9010 STARTING AT 10 5
                                 ENDING   AT 80 8.
      IF sy-subrc = 0.
        CLEAR i_bdc.
        PERFORM f_dynpro USING:
           'X'  'SAPMSVMA'                '0100',
           ' '  'BDC_OKCODE'              '=UPD',
           ' '  'VIEWNAME'                'ZFVATTOP',
           ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
           ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

           'X'  'SAPLSVIX'                '0210',
           ' '  'MARK_CHECKBOX(01)'       'X',
           ' '  'MARK_CHECKBOX(02)'       'X',

           'X'  'SAPLSVIX'                '0100',
           ' '  'BDC_OKCODE'              '=OKAY',
           ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pv_vkorg,
           ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' pv_kdgrp.

        CALL TRANSACTION 'YF01' USING i_bdc
                             MODE 'E'
                             UPDATE 'S'
                             MESSAGES INTO i_messtab.
      ENDIF.

*    WHEN radio7.
*      CALL SELECTION-SCREEN 9004.
*      IF sy-subrc = 0.
*        PERFORM f_get_file_upload.
*        PERFORM f_validate_data_upload.
*        PERFORM f_alv TABLES gt_record.
*      ENDIF.

    WHEN radio8.
      SUBMIT zfcustaddr VIA SELECTION-SCREEN AND RETURN.

    WHEN radio9.
      SUBMIT zfvatdtcust VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

TOP-OF-PAGE.
  PERFORM write_header.

*&---------------------------------------------------------------------*
*&      Form  CEK_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_lock.
  CALL FUNCTION 'ENQUEUE_EZ0005'
    EXPORTING
      vkorg          = p_vkorg
*     VKBUR          = P_VKBUR
    EXCEPTIONS
      foreign_lock   = 4
      system_failure = 8.
  IF sy-subrc EQ 4.
    MESSAGE a000(zf) WITH 'Transaction current process by another W-S'.
  ENDIF.

ENDFORM.                    " CEK_LOCK

*&---------------------------------------------------------------------*
*&      Form  RELEASE_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
  CALL FUNCTION 'DEQUEUE_EZ0005'
    EXPORTING
      vkorg = p_vkorg.
*       VKBUR = P_VKBUR

ENDFORM.                    " RELEASE_LOCK

*&---------------------------------------------------------------------*
*&      Form  process_vat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_vat.

  DATA : BEGIN OF lt_konv OCCURS 0,
           knumv LIKE konv-knumv,
           kbetr LIKE konv-kbetr,
           kwert LIKE konv-kwert,
           kawrt LIKE konv-kawrt,
         END OF lt_konv.

  DATA: lt_leg         LIKE i_live OCCURS 0 WITH HEADER LINE,
        lt_sap         LIKE i_live OCCURS 0 WITH HEADER LINE,
        lt_konvsum     LIKE lt_konv OCCURS 0 WITH HEADER LINE,
        ld_auart       LIKE vbak-auart,
        ld_vgbel       LIKE vbak-vgbel,
        ld_dudat       LIKE i_main-dudat,
        ld_flag(1),
        l_term         LIKE t052-ztag1,
        l_kdgrp        LIKE knvv-kdgrp,
        l_month        TYPE i,
        l_year         TYPE i,
        l_zfbdt        LIKE bsid-zfbdt,
        l_zbd1t        LIKE bsid-zbd1t,
        l_vbelv        LIKE vbfa-vbelv,
        l_vbeln        LIKE vbfa-vbeln,
        l_flag1        LIKE zfvato-flag1,
        l_vatpr        LIKE zfvato-vatpr,
        l_vatno        LIKE zfvato-vatno,
        lw_project     LIKE zproject,
        lw_vatdatptt   LIKE zproject,
        ld_dat1st      TYPE d,
        ld_dat2nd      TYPE d,
        ld_vat_awal(1),
        l_vbeln_ref    LIKE zfvato-vbeln_ref,
        l_zuonr_ref    LIKE zfvato-zuonr_ref,
        l_dueyr_ref    LIKE zfvato-dueyr_ref.

  DATA : lt_sap1  LIKE i_sap OCCURS 0,
         lt_sap2  LIKE i_sap OCCURS 0,
         ls_vbrp  LIKE LINE OF gt_vbrp,
         lv_dpp   TYPE vbrp-netwr,
         lv_ppn_s TYPE vbrp-mwsbp,
         lv_inco1 TYPE vbkd-inco1.

  DATA : lv_mwsk1 TYPE konv-mwsk1.
  DATA : lv_subrc TYPE sy-subrc.

** Revisi by Budi, Req by SJT 24/05/2010
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF lw_vatdatptt
    FROM zproject
    WHERE name = 'VATDATPTT'.
** End Revisi by Budi, Req by SJT 24/05/2010

* Get VAT Out Number
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvatnr
    FROM zfvatnr
    WHERE vkorg = p_vkorg.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Please Maintenance VAT Number'.
    STOP.
  ENDIF.

* Get Trn Code
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvattrn
    FROM zfvattrn
    WHERE vkorg = p_vkorg AND
          vkbur IN s_vkbur.

* Get TOP
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfvattop
    FROM zfvattop
    WHERE vkorg = p_vkorg.

* Get VAT Out Number Detail
  SELECT * INTO CORRESPONDING FIELDS OF TABLE i_zfvatnr_dtl
    FROM zfvatnr_dtl
    WHERE vkorg = p_vkorg.

  PERFORM release_lock.

* Get Branch
  SELECT a~vstel a~werks a~lgort b~legacy_branch b~live b~vatbr
    INTO CORRESPONDING FIELDS OF TABLE i_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE a~vstel IN s_vkbur AND
          b~bukrs = p_vkorg.

  lt_leg[] = i_live[].
  lt_sap[] = i_live[].
  DELETE lt_leg WHERE live NE space.
  DELETE lt_sap WHERE live EQ space.
  REFRESH: r_vkbur_sap, r_vkbur_leg.
  CLEAR: r_vkbur_sap, r_vkbur_leg.
  LOOP AT i_live.
    IF i_live-live = 'X'.
      r_vkbur_sap-low    = i_live-vstel.
      r_vkbur_sap-high   = i_live-vstel.
      r_vkbur_sap-option = 'EQ'.
      r_vkbur_sap-sign   = 'I'.
      APPEND r_vkbur_sap.
    ELSE.
      r_vkbur_leg-low    = i_live-vstel.
      r_vkbur_leg-high   = i_live-vstel.
      r_vkbur_leg-option = 'EQ'.
      r_vkbur_leg-sign   = 'I'.
      APPEND r_vkbur_leg.
    ENDIF.

  ENDLOOP.
* Get Data SAP -----------------------------------------------
  IF NOT r_vkbur_sap IS INITIAL.
    SELECT a~vkorg a~vbeln a~fkdat a~erdat a~zterm a~fkdat_rl
           a~vbtyp a~fkart a~knumv a~zuonr a~netwr
           a~mwsbk a~gjahr a~kunrg a~spart a~xblnr
           a~waerk b~vkbur c~adrnr c~stras c~ort01
*           a~waerk d~vkbur c~adrnr c~stras c~ort01
           c~pstlz c~stceg c~cityc c~gform b~kdgrp
*---------- B001 ----------*
      FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
                     JOIN kna1 AS c ON a~kunrg = c~kunnr
*                     JOIN vbrp AS d ON d~vbeln = a~vbeln AND
*                                       d~posnr = '000010'
      INTO CORRESPONDING FIELDS OF TABLE i_sap
*      FOR ALL ENTRIES IN lt_sap
      WHERE a~vkorg = p_vkorg
        AND a~fkdat IN s_fkdat
        AND a~vbeln IN s_vbeln
        AND a~vbtyp IN ('M','5')
        AND a~erdat IN s_erdat
        AND a~zuonr IN s_zuonr
        AND a~kunrg IN s_kunrg
        AND a~fkart IN gr_fkart
        AND
*            a~fksto EQ space       AND
            b~vkbur IN r_vkbur_sap.
*            d~vkbur IN r_vkbur_sap.
*        AND
*            b~vkbur = lt_sap-vstel AND
*            c~stcd1 EQ space.
  ENDIF.

  IF NOT i_sap[] IS INITIAL.
    PERFORM f_get_vbrp.
** Revisi by Budi, Req by SJT 24/05/2010
* Get VAT Date
    i_saptmp[] = i_sap[].
    SORT i_saptmp BY zuonr.
    DELETE ADJACENT DUPLICATES FROM i_saptmp COMPARING zuonr.
    SELECT * INTO TABLE i_zmm_cust_rec
      FROM zmm_cust_rec
      FOR ALL ENTRIES IN i_saptmp
      WHERE vbeln = i_saptmp-zuonr.
** End Revisi by Budi, Req by SJT 24/05/2010
* Get SO Number sementara comment
    SELECT a~vbeln a~aubel b~auart
      FROM vbrp AS a JOIN vbak AS b ON b~vbeln = a~aubel
      INTO CORRESPONDING FIELDS OF TABLE i_sono
      FOR ALL ENTRIES IN i_sap
      WHERE a~vbeln = i_sap-vbeln.
    SORT i_sono BY aubel.
    DELETE ADJACENT DUPLICATES FROM i_sono COMPARING aubel.
* Get Cancelation
    SELECT a~vbeln zuonr vbtyp sfakn b~vkbur
      FROM vbrk AS a JOIN knvv AS b ON a~kunrg = b~kunnr AND
                                       a~vkorg = b~vkorg AND
                                       a~vtweg = b~vtweg AND
                                       a~spart = b~spart
*      FROM vbrk AS a JOIN vbrp AS b ON b~vbeln = a~vbeln AND
*                                       b~posnr = '000010'
      INTO CORRESPONDING FIELDS OF TABLE i_billcor
      FOR ALL ENTRIES IN i_sap
      WHERE a~vbtyp = 'N'           AND
*      WHERE a~vbtyp IN ('N','6')  AND
            a~vkorg = i_sap-vkorg AND
            b~vkbur = i_sap-vkbur AND
            a~sfakn = i_sap-vbeln AND
            a~zuonr = i_sap-zuonr AND
            a~kunrg = i_sap-kunrg.
* Get Data VAT Out
    SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_zfvato
      FOR ALL ENTRIES IN i_sap
      WHERE vkorg = i_sap-vkorg AND
            vkbur = i_sap-vkbur AND
            vbeln = i_sap-vbeln AND
            zuonr = i_sap-zuonr AND
            blart NE 'GB'    AND
            vtart = 'SD'.

    LOOP AT i_sap.
      IF i_sap-vkbur(2) = 'T2'.
        APPEND i_sap TO lt_sap2.
      ELSE.
        APPEND i_sap TO lt_sap1.
      ENDIF.
    ENDLOOP.

*    lt_sap1[] = i_sap[].
*    DELETE lt_sap1 WHERE vkbur = 'T220'.
*    lt_sap2[] = i_sap[].
*    DELETE lt_sap2 WHERE vkbur <> 'T220'.

* Get Data KONV
    IF lt_sap1[] IS NOT INITIAL.
      SELECT knumv kbetr kwert
        FROM konv
        INTO CORRESPONDING FIELDS OF TABLE lt_konv
        FOR ALL ENTRIES IN lt_sap1
        WHERE knumv = lt_sap1-knumv
          AND koaid = 'B'
          AND kntyp = space.
    ENDIF.

    IF lt_sap2[] IS NOT INITIAL.
      IF p_bahan IS INITIAL.
        SELECT knumv kposn kbetr kwert
          FROM konv
          APPENDING CORRESPONDING FIELDS OF TABLE lt_konv
          FOR ALL ENTRIES IN lt_sap2
          WHERE knumv = lt_sap2-knumv
            AND koaid = 'B'
            AND kntyp = space
            AND kschl = 'ZNOL'
            AND mwsk1 = 'A3'
            AND sakn1 = '0611510100'.
      ELSE.
        SELECT knumv kposn kbetr kwert kawrt
        FROM konv
        APPENDING CORRESPONDING FIELDS OF TABLE lt_konv
        FOR ALL ENTRIES IN lt_sap2
        WHERE knumv = lt_sap2-knumv
          AND koaid = 'D'
          AND kntyp = 'D'
          AND kschl = 'ZVAT'
          AND krech = 'A'
          AND mwsk1 = 'A3'.
      ENDIF.
    ENDIF.
**** Get Data KONV
***    SELECT knumv kbetr kwert
***      FROM konv
***      INTO CORRESPONDING FIELDS OF TABLE lt_konv
***      FOR ALL ENTRIES IN i_sap
***      WHERE knumv = i_sap-knumv AND
***            koaid = 'B'         AND
***            kntyp = space.
    LOOP AT lt_konv.
      MOVE-CORRESPONDING lt_konv TO lt_konvsum.
      COLLECT lt_konvsum. CLEAR lt_konvsum.
    ENDLOOP.

****** Diremark karena berpengaruh ke performance 8-02-2008
** Get Data faktur pengganti
*    SELECT *
*      FROM zbil AS a JOIN vbrp AS b ON b~aubel = a~sono_gnt AND
*                                       b~posnr = '10'
*      INTO CORRESPONDING FIELDS OF TABLE i_zbil
**      FOR ALL ENTRIES IN i_sap
*      WHERE a~vkorg = p_vkorg      AND
*            a~vkbur IN r_vkbur_sap AND
*            a~status = 'A'         AND
*            a~sono NE space        AND
*            a~dono_kor NE space    AND
*            a~vbeln_kor NE space   AND
*            a~sono_gnt NE space    AND
*            a~dono_gnt = space     AND
*            a~vbeln_gnt = space    AND
*            a~cityc_ganti = space  AND
*            a~vatno_ganti = space.
********* end Remark
  ENDIF.


* Get Data Legacy -----------------------------------------
*  IF NOT lt_leg[] IS INITIAL.
  IF NOT  r_vkbur_leg IS INITIAL.
    SELECT a~vkorg a~vbeln a~fkdat a~bldat
           a~vbtyp a~fkart a~netwr a~txdat
           a~mwsbp a~gjahr a~kunnr a~curr
           a~vkbur a~kunde a~spdot a~vrtnr a~sonr a~status
           a~grswr a~account_no a~filename a~kir a~budat
           a~taxcode
           c~adrnr c~stras c~ort01 c~pstlz
           c~stceg c~cityc c~gform
      FROM zsl_hsales AS a JOIN kna1 AS c ON a~kunnr = c~kunnr
      INTO CORRESPONDING FIELDS OF TABLE i_legacy
*      FOR ALL ENTRIES IN lt_leg
      WHERE a~vkbur IN r_vkbur_leg
        AND a~vbtyp IN ('M','5')
        AND a~stafjk = space
        AND a~vkorg = p_vkorg
        AND a~z_uplod = space
        AND a~bldat IN s_erdat
        AND a~account_no IN s_vbeln
        AND a~vbeln IN s_zuonr
        AND a~kunnr IN s_kunrg
        AND a~spdot IN s_spdot
        AND a~account_no NE space
        AND a~status NE '4'
        AND a~upl_cancel EQ '00000000'.
*        AND c~stcd1 EQ space.
  ENDIF.

  IF NOT i_legacy[] IS INITIAL.
    SELECT *
      FROM zfvato
      INTO CORRESPONDING FIELDS OF TABLE i_zfvato_leg
      FOR ALL ENTRIES IN i_legacy
      WHERE vkorg = i_legacy-vkorg AND
            vkbur = i_legacy-vkbur AND
            vbeln = i_legacy-account_no AND
*            zuonr = i_legacy-vbeln AND
            blart NE 'GB'    AND
            vtart = 'SD'.
  ENDIF.

  SORT i_legacy BY vkorg vkbur vbeln.
  SORT i_sap BY vkorg vkbur zuonr.
  SORT i_zfvato BY vkorg vkbur zuonr.
  SORT i_zfvato_leg BY vkorg vkbur zuonr.

*-------------------------------------------------------------
* Process Data SAP
*-------------------------------------------------------------

  CLEAR : d_datab, d_flag.
  SELECT SINGLE datab flag
     INTO (d_datab, d_flag)
     FROM zproject
     WHERE name = 'PAJAK'.

  LOOP AT i_sap.
* Check Cancelation
    READ TABLE i_billcor WITH KEY vkbur = i_sap-vkbur
                                  zuonr = i_sap-zuonr
                                  sfakn = i_sap-vbeln.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
* Check Double
    CLEAR: lv_subrc.
    IF p_bahan IS INITIAL.
      READ TABLE i_zfvato WITH KEY vkorg = i_sap-vkorg
                                   vkbur = i_sap-vkbur
*                                  vbeln = i_sap-vbeln
                                   zuonr = i_sap-zuonr.
      IF sy-subrc NE 0.
        lv_subrc = 4.
      ELSE.
        LOOP AT i_zfvato WHERE vkorg = i_sap-vkorg
                           AND vkbur = i_sap-vkbur
                           AND zuonr = i_sap-zuonr.
          IF i_zfvato-vatpr(2) NE '08'.
            lv_subrc = 0.
            EXIT.
          ENDIF.
          IF i_zfvato-vatpr(2) EQ '08'.
            lv_subrc = 4.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      READ TABLE i_zfvato WITH KEY vkorg = i_sap-vkorg
                                   vkbur = i_sap-vkbur
                                   zuonr = i_sap-zuonr
                                   vatpr(2) = '08'.
      lv_subrc = sy-subrc.
    ENDIF.

    IF lv_subrc = 0.
      CONTINUE.
    ENDIF.
** Revisi by Budi, Req by SJT 24/05/2010
* Check VAT Date
    CLEAR: ld_dudat, i_zmm_cust_rec, i_sono, ld_flag.
    IF i_sap-fkdat GE lw_vatdatptt-datab AND lw_vatdatptt-flag = 'X'.
      READ TABLE i_zmm_cust_rec WITH KEY vbeln = i_sap-zuonr.
      IF sy-subrc = 0.
        IF i_zmm_cust_rec-txdat IS NOT INITIAL.
          ld_dudat = i_zmm_cust_rec-txdat.
        ELSE.
          CONTINUE.
        ENDIF.
      ELSE.
        ld_flag = 'X'.
        CLEAR: ld_dudat.
      ENDIF.
    ENDIF.
** End Revisi by Budi, Req by SJT 24/05/2010

    MOVE-CORRESPONDING i_sap TO i_main.

* Get Total Value
    CLEAR lt_konvsum.
    READ TABLE lt_konvsum WITH KEY knumv = i_main-knumv.
    IF p_bahan IS INITIAL.
      i_main-tkwert = lt_konvsum-kwert.
    ELSE.
      i_main-tkwert = lt_konvsum-kawrt.
    ENDIF.

    IF i_main-fkdat LT '20070101'.
      IF i_sap-vbtyp = 'M'.
        SELECT SINGLE vbelv
          FROM vbfa
          INTO i_main-vbelv
          WHERE vbeln = i_sap-vbeln   AND
                vbtyp_n = i_sap-vbtyp AND
                stufe = '01'            AND
                vbtyp_v = 'C'.
      ELSE.
        SELECT SINGLE vbelv
          FROM vbfa
          INTO i_main-vbelv
          WHERE vbeln = i_sap-vbeln   AND
                vbtyp_n = i_sap-vbtyp AND
                vbtyp_v = 'J'.
      ENDIF.
      SELECT SINGLE mahdt ihrez audat
        FROM vbak
        INTO CORRESPONDING FIELDS OF i_main
        WHERE vbeln = i_main-vbelv.
    ENDIF.

    SELECT SINGLE name_co str_suppl1 str_suppl2
           str_suppl3 location
      FROM adrc
      INTO (i_main-name_co, i_main-str_suppl1, i_main-str_suppl2,
            i_main-stras, i_main-location)
      WHERE addrnumber = i_sap-adrnr.

    SELECT SINGLE kunnr
      FROM vbpa
      INTO i_main-kunde
      WHERE vbeln = i_sap-vbeln AND
            parvw = 'ZS'.

    SELECT SINGLE pernr
      FROM vbpa
      INTO i_main-vrtnr
      WHERE vbeln = i_main-vbeln AND
            parvw = 'VE'.

* Get Due Date
** Revisi by Budi, Req by SJT 24/05/2010
    IF ld_dudat IS NOT INITIAL.
      i_main-dudat = ld_dudat.
    ELSE.
** End Revisi by Budi, Req by SJT 24/05/2010
*      IF i_sap-cityc = 'T1'.
      IF i_sap-cityc NE 'T0'.
        CLEAR: l_term,l_kdgrp.
        IF i_main-vbtyp = 'M' OR i_main-vbtyp = '5'.

* add by Sukardi 15/06/2007
* Req By HGN/SJT untuk project pajak (Ganti tanggal billing)
* Project ini sekaligus mematikan add by budi
* table zproject untuk kontrol go live project.
*

          IF i_main-fkdat < d_datab  AND d_flag = 'X'.
            IF i_main-fkdat GE '20070101'.
              IF p_dudat IS INITIAL.
                READ TABLE i_zfvattop WITH KEY vkorg = i_main-vkorg
                                               kdgrp = i_sap-kdgrp.
                IF sy-subrc = 0.
                  i_main-dudat = i_main-fkdat + i_zfvattop-zterm.
                ELSE.
                  i_main-dudat = i_main-fkdat + 7.
                ENDIF.
              ELSE.
                i_main-dudat = p_dudat.
              ENDIF.
            ELSE.
              i_main-dudat = i_main-mahdt.
            ENDIF.
***** End
*     Req. By LIP/SJT 28/12/2006

          ELSE.
            IF p_dudat IS INITIAL.
              READ TABLE i_zfvattop WITH KEY vkorg = i_main-vkorg
                                             kdgrp = i_sap-kdgrp.
              IF sy-subrc = 0.
                i_main-dudat = i_main-fkdat + i_zfvattop-zterm.
              ELSE.
                i_main-dudat = i_main-fkdat.
              ENDIF.
            ELSE.
              i_main-dudat = p_dudat.
            ENDIF.

          ENDIF.
        ENDIF.
      ELSE.
        i_main-dudat = i_main-fkdat.
      ENDIF.
    ENDIF.

* Hitung Ulang Due Date
** Revisi by Budi, Req by SJT 24/05/2010
    IF ld_dudat IS INITIAL.
** End Revisi by Budi, Req by SJT 24/05/2010
      CLEAR: l_year, l_month.
      l_year =  i_main-dudat(4) - i_main-fkdat(4).
      l_month = ( i_main-dudat+4(2) - i_main-fkdat+4(2) ) +
                 l_year * 12.
      IF l_month GT 1.
        CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
          EXPORTING
            months  = 1
            olddate = i_main-fkdat
          IMPORTING
            newdate = i_main-dudat.
      ENDIF.
    ENDIF.

* Emergency Condisi
    IF ld_flag = 'X' AND i_main-dudat LT '20100604'.
      i_main-dudat = '20100604'.
    ENDIF.

* Check VAT Date
    PERFORM f_check_vat_date USING    i_main-dudat(4)
                             CHANGING r_dudat.
    IF r_dudat[] IS INITIAL.
      CONTINUE.
    ELSE.
      IF NOT i_main-dudat IN r_dudat.
        CONTINUE.
      ENDIF.
    ENDIF.

* Change BLDAT -> FKDAT
    SELECT SINGLE wadat_ist INTO i_main-fkdat FROM likp WHERE vbeln = i_main-zuonr.

* Update ZMM_CUST_REC
    READ TABLE i_zmm_cust_rec WITH KEY vbeln = i_sap-zuonr.
    IF sy-subrc IS INITIAL.
      i_zmm_cust_rec-txsts = 'X'.
      MODIFY i_zmm_cust_rec TRANSPORTING txsts WHERE vbeln = i_sap-zuonr.
    ENDIF.

* Append To Itab Main
    CLEAR: lt_sap.
*    READ TABLE lt_sap WITH KEY vstel = i_main-vkbur.
*    i_main-vatbr = lt_sap-vatbr.

    CLEAR lv_inco1.
    READ TABLE i_sono WITH KEY vbeln = i_sap-vbeln.
    SELECT SINGLE inco1
      FROM vbkd
      INTO lv_inco1
      WHERE vbeln = i_sono-aubel.

    IF lv_inco1 = 'A2'.
      i_main-gform = lv_inco1.
    ELSE.
      i_main-gform = i_sap-gform.
    ENDIF.

    i_main-cityc = i_sap-cityc.
    i_main-ihrez = '00000000'.
    i_main-vtart = 'SD'.
    i_main-gsber = '0200'.

    CLEAR : ls_vbrp, lv_dpp, lv_ppn_s.
    LOOP AT gt_vbrp INTO ls_vbrp WHERE vbeln = i_sap-vbeln.
      ADD ls_vbrp-netwr TO lv_dpp.
      ADD ls_vbrp-mwsbp TO lv_ppn_s.
    ENDLOOP.
    i_main-netwr = i_main-netwr - lv_dpp.
    IF p_bahan IS NOT INITIAL.
      i_main-netwr = i_main-tkwert.
    ENDIF.
    i_main-mwsbk = i_main-mwsbk - lv_ppn_s.
    IF i_main-netwr = 0.
      CONTINUE.
    ENDIF.
*    i_main-dpp   = i_main-netwr * 100.
    i_main-dpp    = ( i_main-netwr * 100 ) * 11 / 12.
    i_main-dueyr = i_main-dudat(4).
    i_main-duemm = i_main-dudat+4(2).
    i_main-prodt = sy-datum.
    i_main-protm = sy-uzeit.
    i_main-prous = sy-uname.

* Faktur Pengganti
    IF i_sap-vbtyp = 'M'.
      SELECT SINGLE vbelv
        FROM vbfa
        INTO i_main-vbelv
        WHERE vbeln = i_sap-vbeln   AND
              vbtyp_n = i_sap-vbtyp AND
              stufe = '01'            AND
              vbtyp_v = 'C'.
    ELSE.
      SELECT SINGLE vbelv
        FROM vbfa
        INTO i_main-vbelv
        WHERE vbeln = i_sap-vbeln   AND
              vbtyp_n = i_sap-vbtyp AND
              vbtyp_v = 'J'.
    ENDIF.
    SELECT SINGLE auart vgbel
      FROM vbak
      INTO (ld_auart,ld_vgbel)
      WHERE vbeln = i_main-vbelv.
    IF sy-subrc = 0.
      IF ld_auart(3) = 'ZOA'.
        SELECT SINGLE vgbel zuonr
          FROM vbak
          INTO (i_main-vbeln_ref,i_main-zuonr_ref)
          WHERE vbeln = ld_vgbel.
        i_main-flag1 = 'K'.
        i_main-flkor = 'K'.
      ENDIF.
    ENDIF.

    APPEND i_main. CLEAR i_main.
  ENDLOOP.


*-------------------------------------------------------------
* Process Data Legacy
*-------------------------------------------------------------
  LOOP AT i_legacy.
* Check Double
    READ TABLE i_zfvato_leg WITH KEY vkorg = i_legacy-vkorg
                                     vkbur = i_legacy-vkbur
                                     zuonr = i_legacy-vbeln
                                     vbeln = i_legacy-account_no.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
** Revisi by Budi, Req by SJT 24/05/2010
* Check VAT Date
    CLEAR ld_dudat.
    IF i_legacy-budat GE lw_vatdatptt-datab AND lw_vatdatptt-flag = 'X'.
      IF i_legacy-txdat IS NOT INITIAL.
        ld_dudat = i_legacy-txdat.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.
** End Revisi by Budi, Req by SJT 24/05/2010

* Move Fields
    i_main-vkorg = i_legacy-vkorg.
    i_main-zuonr = i_legacy-vbeln.
    i_main-vbeln1 = i_legacy-vbeln.
    i_main-erdat = i_legacy-fkdat.
    i_main-bldat = i_legacy-bldat.
    i_main-budat = i_legacy-budat.
    i_main-fkdat_rl = i_legacy-bldat.
    i_main-fkdat = i_legacy-budat.
    i_main-vbtyp = i_legacy-vbtyp.
    i_main-fkart = i_legacy-fkart.
    i_main-netwr = i_legacy-netwr.

* add by Sukardi 15/06/2007
* Req By HGN/SJT untuk project pajak (Ganti tanggal billing)
* Project ini sekaligus mematikan add by budi
* table zproject untuk kontrol go live project.
*
    i_main-dudat = i_legacy-txdat.
*** End Add
    i_main-mwsbk = i_legacy-mwsbp.
    i_main-gjahr = i_legacy-gjahr.
    i_main-kunrg = i_legacy-kunnr.
    i_main-waerk = i_legacy-curr.
    i_main-vkbur = i_legacy-vkbur.
    i_main-kunde = i_legacy-kunde.
    i_main-ihrez = i_legacy-spdot.
    i_main-vrtnr = i_legacy-vrtnr.
    i_main-tkwert = i_legacy-grswr.
    i_main-vbeln = i_legacy-account_no.
    i_main-adrnr = i_legacy-adrnr.
    i_main-stras = i_legacy-stras.
    i_main-ort01 = i_legacy-ort01.
    i_main-pstlz = i_legacy-pstlz.
    i_main-stceg = i_legacy-stceg.
    i_main-cityc = i_legacy-cityc.

    SELECT SINGLE name_co str_suppl1 str_suppl2
           str_suppl3 location
      FROM adrc
      INTO (i_main-name_co, i_main-str_suppl1, i_main-str_suppl2,
            i_main-stras, i_main-location)
      WHERE addrnumber = i_legacy-adrnr.

* Get Due Date
    CLEAR: l_term,l_kdgrp.
* Req. By LIP/SJT 28/12/2006
** Revisi by Budi, Req by SJT 24/05/2010
    IF ld_dudat IS NOT INITIAL.
      i_main-dudat = ld_dudat.
    ELSE.
** End Revisi by Budi, Req by SJT 24/05/2010
*      IF i_legacy-cityc = 'T1'.
      IF i_legacy-cityc NE 'T0'.
        IF i_main-fkdat GE '20070101'.
          IF p_dudat IS INITIAL.
            SELECT SINGLE kdgrp FROM knvv INTO l_kdgrp
                  WHERE kunnr = i_main-kunrg AND
                        vkorg = i_main-vkorg.
            READ TABLE i_zfvattop WITH KEY vkorg = i_main-vkorg
                                           kdgrp = l_kdgrp.
            IF sy-subrc = 0.
              i_main-dudat = i_main-fkdat + i_zfvattop-zterm.
            ELSE.
              i_main-dudat = i_main-fkdat + 7.
            ENDIF.
          ELSE.
            i_main-dudat = p_dudat.
          ENDIF.
        ENDIF.
        IF i_legacy-bldat < d_datab  AND d_flag = 'X'.
        ELSE.
          IF p_dudat IS INITIAL.
            SELECT SINGLE kdgrp FROM knvv INTO l_kdgrp
                  WHERE kunnr = i_main-kunrg AND
                        vkorg = i_main-vkorg.
            READ TABLE i_zfvattop WITH KEY vkorg = i_main-vkorg
                                           kdgrp = l_kdgrp.
            IF sy-subrc = 0.
              i_main-dudat = i_legacy-budat + i_zfvattop-zterm.
            ELSE.
              i_main-dudat = i_legacy-budat.
            ENDIF.
          ELSE.
            i_main-dudat = p_dudat.
          ENDIF.
        ENDIF.
      ELSE.
        i_main-dudat = i_main-fkdat.
      ENDIF.
    ENDIF.

* Hitung Ulang Due Date
** Revisi by Budi, Req by SJT 24/05/2010
    IF ld_dudat IS INITIAL.
** End Revisi by Budi, Req by SJT 24/05/2010
      CLEAR: l_year, l_month.
      l_year =  i_main-dudat(4) - i_main-fkdat(4).
      l_month = ( i_main-dudat+4(2) - i_main-fkdat+4(2) ) +
                 l_year * 12.
      IF l_month GT 1.
        CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
          EXPORTING
            months  = 1
            olddate = i_main-fkdat
          IMPORTING
            newdate = i_main-dudat.
      ENDIF.
    ENDIF.

* Check VAT Date
    PERFORM f_check_vat_date USING    i_main-dudat(4)
                             CHANGING r_dudat.
    IF r_dudat[] IS INITIAL.
      CONTINUE.
    ELSE.
      IF NOT i_main-dudat IN r_dudat.
        CONTINUE.
      ENDIF.
    ENDIF.

* Append To Itab Main
    CLEAR: lt_leg.
*    READ TABLE lt_leg WITH KEY vstel = i_main-vkbur.
*    i_main-vatbr = lt_leg-vatbr.
* COVID 19
    IF i_legacy-taxcode IS INITIAL.
      i_main-gform = i_legacy-gform.
    ELSE.
      i_main-gform = i_legacy-taxcode.
    ENDIF.
    i_main-vtart = 'SD'.
    i_main-gsber = '0200'.
    i_main-spart = '00'.

    PERFORM f_tax_calc USING i_main-budat i_main-netwr 'A'
                       CHANGING i_main-dpp.

*    i_main-dpp = ( i_main-netwr * 100 ) / ( 110 / 100 ).

    i_main-dueyr = i_main-dudat(4).
    i_main-duemm = i_main-dudat+4(2).
*    i_main-xblnr = i_legacy-filename+3(4).
    i_main-xblnr = i_legacy-kir.
    i_main-prodt = sy-datum.
    i_main-protm = sy-uzeit.
    i_main-prous = sy-uname.

* Faktur Pengganti
    IF i_legacy-status = '5'.
      CLEAR: l_flag1, l_vatpr, l_vatno, l_vbeln_ref, l_zuonr_ref, l_dueyr_ref.
      PERFORM faktur_pengganti CHANGING l_flag1
                                        l_vatpr
                                        l_vatno
                                        l_vbeln_ref
                                        l_zuonr_ref
                                        l_dueyr_ref.
      i_main-flag1 = l_flag1.
      i_main-vatpr = l_vatpr.
      i_main-vatno = l_vatno.
      i_main-vbeln_ref = l_vbeln_ref.
      i_main-zuonr_ref = l_zuonr_ref.
      i_main-dueyr_ref = l_dueyr_ref.
      i_main-flkor = l_flag1.
    ENDIF.

    APPEND i_main. CLEAR i_main.
  ENDLOOP.

** Revisi by Budi, Req by SJT 18/03/2010
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF lw_project
    FROM zproject
    WHERE name = 'VATOUTPTT'.
** End Revisi by Budi, Req by SJT 18/03/2010

  DATA: lt_tline     TYPE TABLE OF tline WITH HEADER LINE,
        lv_name      TYPE tdobname,
        lv_tdmacode1 TYPE tdmacode1,
        lv_header    LIKE thead.

  FIELD-SYMBOLS: <fs_main> LIKE i_main.

* Get VAT Number
  SORT i_main BY dudat vkbur.
  LOOP AT i_main.

    ASSIGN i_main TO <fs_main>.

    CASE <fs_main>-gform.
      WHEN 'A3' OR 'A4'.
        CLEAR: lv_name,lv_tdmacode1.
        lv_name = <fs_main>-vbeln.

        SELECT SINGLE tdmacode1 INTO lv_tdmacode1
          FROM stxh WHERE tdobject = 'VBBK'
                      AND tdname   = lv_name
                      AND tdid     = '0021'
                      AND tdspras  = sy-langu.

        IF sy-subrc = 0.
          CLEAR: lv_header,lt_tline[].
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id       = '0021'
              language = sy-langu
              name     = lv_name
              object   = 'VBBK'
            IMPORTING
              header   = lv_header
            TABLES
              lines    = lt_tline.

          IF sy-subrc EQ 0.
            READ TABLE lt_tline INDEX 1.
            IF lt_tline-tdline = 'A1'.
              <fs_main>-gform = 'A1'.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
    UNASSIGN <fs_main>.

*    IF i_main-cityc = 'T1'.
    IF i_main-cityc NE 'T0'.
      CLEAR: v_vatto,v_vatno,v_vatpr,i_main-vatbr,wa_zfvatnr_dtl.
      PERFORM f_get_vat_number USING    i_main-dudat
                                        i_main-vkbur
                                        i_main-gform
                                        i_main-flkor      "add by Budi 04/06/2013
                                        i_main-zuonr_ref  "add by Budi 04/06/2013
                                        i_main-vbeln_ref  "add by Budi 04/06/2013
                               CHANGING v_vatto
                                        v_vatno
                                        v_vatold
                                        v_vatpr
                                        i_main-vatbr
                                        i_main-vatno
                                        i_main-dueyr_ref
                                        wa_zfvatnr_dtl.
      IF v_vatno GT v_vatto.
        DELETE i_main. CONTINUE.
      ENDIF.
*      IF i_main-flag1 = 'G'.
* command by Budi 04/06/2013
*      IF i_main-flag1 = 'G' OR i_main-flag1 = 'K'.
*        v_vatpr+2(1) = '1'.
*      ENDIF.
* end command by Budi 04/06/2013

      i_main-vatpr = v_vatpr.
*      i_main-vatno = v_vatno.
      i_zfvatnr-vatno = v_vatno.
      i_zfvatnr-vatold = v_vatold.

      IF i_main-dudat GE '20070101'.
        IF i_main-vatbr IS INITIAL.
          DELETE i_main. CONTINUE.
        ENDIF.

*  Rev. by Budi 15/03/2013 Req. by SJT.
        IF i_main-flkor IS INITIAL.
          IF v_flg_pajak2013 IS NOT INITIAL AND
             v_dat_pajak2013 LE i_main-dudat.
            i_main-vatno = v_vatno.

            IF wa_zfvatnr_dtl IS NOT INITIAL.
              i_zfvatnr-vatfr = wa_zfvatnr_dtl-vatfr.
              i_zfvatnr-vatto = wa_zfvatnr_dtl-vatto.
              i_zfvatnr-vatpr = wa_zfvatnr_dtl-vatpr.
              i_zfvatnr-vatdt = wa_zfvatnr_dtl-vatdt.
              i_zfvatnr-vatcd = wa_zfvatnr_dtl-vatcd.
              i_zfvatnr-posnr = wa_zfvatnr_dtl-posnr.
              MODIFY i_zfvatnr TRANSPORTING vatno vatfr vatto vatpr vatdt vatcd posnr
                               WHERE vkorg = p_vkorg AND
                                     vkbur = i_main-vatbr AND
                                     gjahr = i_main-dudat(4).
            ELSE.
              MODIFY i_zfvatnr TRANSPORTING vatno
                               WHERE vkorg = p_vkorg AND
                                     vkbur = i_main-vatbr AND
                                     gjahr = i_main-dudat(4).
            ENDIF.
          ELSE.
*  End Rev. by Budi 15/03/2013 Req. by SJT
            i_main-vatno = v_vatold.
            MODIFY i_zfvatnr TRANSPORTING vatold
                             WHERE vkorg = p_vkorg AND
                                   vkbur = i_main-vatbr AND
                                   gjahr = i_main-dudat(4).
          ENDIF.
        ENDIF.
      ELSE.
        IF i_main-flkor IS INITIAL.
          MODIFY i_zfvatnr TRANSPORTING vatno
                           WHERE vkorg = p_vkorg AND
                                 vkbur = '0200'.
        ENDIF.
      ENDIF.
** Revisi by Budi, Req by SJT 18/03/2010
    ELSE.
** Jika tgl pajak beda bulan dg tgl posting
**  maka tgl pajak = tgl akhir bulan
      IF i_main-dudat(6) NE i_main-fkdat(6).
        CLEAR: ld_dat1st, ld_dat2nd.
        CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
          EXPORTING
            iv_date             = i_main-fkdat
          IMPORTING
            ev_month_begin_date = ld_dat1st
            ev_month_end_date   = ld_dat2nd.
        i_main-dudat = ld_dat2nd.
        MODIFY i_main TRANSPORTING dudat.
      ENDIF.
**
      IF i_main-fkdat GE lw_project-datab AND
         lw_project-flag = 'X'.
        CLEAR: v_vatto, v_vatno, v_vatpr, wa_zfvatnr_dtl.
        PERFORM f_get_vat_number USING    i_main-dudat
                                          i_main-vkbur
                                          i_main-gform
                                          i_main-flkor      "add by Budi 04/06/2013
                                          i_main-zuonr_ref  "add by Budi 04/06/2013
                                          i_main-vbeln_ref  "add by Budi 04/06/2013
                                 CHANGING v_vatto
                                          v_vatno
                                          v_vatold
                                          v_vatpr
                                          i_main-vatbr
                                          i_main-vatno
                                          i_main-dueyr_ref
                                          wa_zfvatnr_dtl.
        IF v_vatno GT v_vatto.
          DELETE i_main. CONTINUE.
        ENDIF.
*        IF i_main-flag1 = 'G'.
* command by Budi 04/06/2013
*        IF i_main-flag1 = 'G' OR i_main-flag1 = 'K'.
*          v_vatpr+2(1) = '1'.
*        ENDIF.
* end command by Budi 04/06/2013

        i_main-vatpr = v_vatpr.
*        i_zfvatnr-vatno = i_main-vatno.
        i_zfvatnr-vatno = v_vatno.
        i_zfvatnr-vatold = v_vatold.

        IF i_main-dudat GE '20070101'.
          IF i_main-vatbr IS INITIAL.
            DELETE i_main. CONTINUE.
          ENDIF.

*  Rev. by Budi 15/03/2013 Req. by SJT
          IF i_main-flkor IS INITIAL.
            IF v_flg_pajak2013 IS NOT INITIAL AND
               v_dat_pajak2013 LE i_main-dudat.
              i_main-vatno = v_vatno.

              IF wa_zfvatnr_dtl IS NOT INITIAL.
                i_zfvatnr-vatfr = wa_zfvatnr_dtl-vatfr.
                i_zfvatnr-vatto = wa_zfvatnr_dtl-vatto.
                i_zfvatnr-vatpr = wa_zfvatnr_dtl-vatpr.
                i_zfvatnr-vatdt = wa_zfvatnr_dtl-vatdt.
                i_zfvatnr-vatcd = wa_zfvatnr_dtl-vatcd.
                i_zfvatnr-posnr = wa_zfvatnr_dtl-posnr.
                MODIFY i_zfvatnr TRANSPORTING vatno vatfr vatto vatpr vatdt vatcd posnr
                                 WHERE vkorg = p_vkorg AND
                                       vkbur = i_main-vatbr AND
                                       gjahr = i_main-dudat(4).
              ELSE.
                MODIFY i_zfvatnr TRANSPORTING vatno
                                 WHERE vkorg = p_vkorg AND
                                       vkbur = i_main-vatbr AND
                                       gjahr = i_main-dudat(4).
              ENDIF.
            ELSE.
*  End Rev. by Budi 15/03/2013 Req. by SJT
              i_main-vatno = v_vatold.
              MODIFY i_zfvatnr TRANSPORTING vatold
                               WHERE vkorg = p_vkorg AND
                                     vkbur = i_main-vatbr AND
                                     gjahr = i_main-dudat(4).
            ENDIF.
          ENDIF.
        ELSE.
          IF i_main-flkor IS INITIAL.
            MODIFY i_zfvatnr TRANSPORTING vatno
                             WHERE vkorg = p_vkorg AND
                                   vkbur = '0200'.
          ENDIF.
        ENDIF.
      ENDIF.
** End Revisi by Budi, Req by SJT 18/03/2010
    ENDIF.

*  Rev. by Budi 15/03/2013 Req. by SJT
    ld_vat_awal = '1'.
*    IF i_main-flkor IS NOT INITIAL.
*      PERFORM f_faktur_pengganti_2013 TABLES   r_vkbur_sap r_vkbur_leg
*                                      CHANGING i_main ld_vat_awal.
*    ENDIF.
*  End Rev. by Budi 15/03/2013 Req. by SJT

    IF ld_vat_awal = '0'.
      DELETE i_main.
    ELSEIF ld_vat_awal = '1'.
      MODIFY i_main TRANSPORTING vatno vatpr dudat dueyr_ref.
    ENDIF.

    IF NOT i_zbil[] IS INITIAL.
      i_zbil-vatno_ganti = i_main-vatpr.
      MODIFY i_zbil TRANSPORTING vatno_ganti
                    WHERE vkorg = i_main-vkorg AND
                          vkbur = i_main-vkbur AND
                          dono_gnt = i_main-zuonr AND
                          vbeln_gnt = i_main-vbeln.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " process_vat

*&---------------------------------------------------------------------*
*&      Form  main_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM main_number.

  IF p_new = 'X'.
    s2vkorg = p_vkorg.
    s2vkbur = p_vatbr.
    s2gjahr = p_vatyr.
    SELECT SINGLE vatno vatfr vatto
                  vatpr vatdt vatold posnr
      FROM zfvatnr
      INTO (s2vatno, s2vatfr, s2vatto,
            s2vatpr, s2vatdt, s2vatold, s2posnr)
      WHERE vkorg = s2vkorg AND
            vkbur = s2vkbur AND
            gjahr = s2gjahr.
    IF sy-subrc = 0.
      vflag1 = 1.
    ENDIF.
  ELSE.
    s2vkorg = p_vkorg.
    s2vkbur = p_vkbur.
    SELECT SINGLE bezei FROM tvkbt
      INTO s2vkburt
      WHERE vkbur = s2vkbur AND
            ( spras = 'E' OR spras = 'EN' ).
    SELECT SINGLE vatno vatfr vatto
                  vatpr vatdt gjahr vatold
      FROM zfvatnr
      INTO (s2vatno, s2vatfr, s2vatto,
            s2vatpr, s2vatdt, s2gjahr, s2vatold)
      WHERE vkorg = s2vkorg AND
            vkbur = s2vkbur.
    IF sy-subrc = 0.
      vflag1 = 1.
    ENDIF.
  ENDIF.

  SELECT SINGLE vtext FROM tvkot
    INTO s2vkorgt
    WHERE vkorg = s2vkorg AND
          ( spras = 'E' OR spras = 'EN' ).
  PERFORM release_lock.

  IF v_flg_pajak2013 IS INITIAL.
    CALL SCREEN 200.
  ELSE.
    PERFORM f_init_screen_210.
    CALL SCREEN 210.
  ENDIF.

ENDFORM.                    " main_number

*&---------------------------------------------------------------------*
*&      Form  main_sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM main_sign.

  s3vkorg = p_vkorg.
  s3vkbur = p_vkbur.
  SELECT SINGLE vtext FROM tvkot
    INTO s3vkorgt
    WHERE vkorg = s3vkorg AND
          ( spras = 'E' OR spras = 'EN' ).
  SELECT SINGLE bezei FROM tvkbt
    INTO s3vkburt
    WHERE vkbur = s3vkbur AND
          ( spras = 'E' OR spras = 'EN' ).
  SELECT SINGLE vatnm vattl object1 vatnm2 vattl2 object2
                vatnm3 vattl3 object3
    FROM zfvatnm
    INTO (s3vatnm, s3vattl, s3object1, s3vatnm2, s3vattl2, s3object2,
          s3vatnm3, s3vattl3, s3object3 )
    WHERE vkorg = p_vkorg AND
          vkbur = p_vkbur AND
          vtart = 'SD'.
  CALL SCREEN 300.

ENDFORM.                    " main_sign

*&---------------------------------------------------------------------*
*&      Form  write_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_table.

  DATA: l_record      TYPE i,
        l_text(40),
        lt_zfvato     LIKE zfvato OCCURS 0 WITH HEADER LINE,
        lt_zsl_hsales LIKE zsl_hsales OCCURS 0 WITH HEADER LINE.

* Check data ada atau tidak
  DESCRIBE TABLE i_main LINES l_record.
  IF l_record IS INITIAL.
    MESSAGE s000(zf) WITH 'No Data'.
    STOP.
  ELSE.
    MESSAGE s000(zf) WITH l_record 'Processed'.
  ENDIF.

* Write List
  LOOP AT i_main WHERE flag1 = space.
    CLEAR i_live.
    READ TABLE i_live WITH KEY vstel = i_main-vkbur
                               live  = 'X'.
    IF sy-subrc = 0.
      CLEAR i_main-xblnr.
    ENDIF.

    CLEAR l_text.
    IF i_main-fkdat < d_datab  AND d_flag = 'X'.
      WRITE: /     '|',
               (5) i_main-vkbur, '|',
              (20) i_main-zuonr, '|',
                   i_main-fkdat, '|',
                   i_main-erdat, '|',
                   i_main-kunrg, '|',
              (40) i_main-name_co, '|',
              (20) i_main-stceg, '|',
                   i_main-vatpr, '|',
                   i_main-dudat, '|'.
      IF i_main-fkdat > gs_dpp-datab.
        WRITE : (15) i_main-dpp DECIMALS 0, '|'.
      ELSE.
        WRITE : (15) i_main-netwr CURRENCY 'IDR', '|'.
      ENDIF.
*            (15) i_main-tkwert CURRENCY 'IDR', '|',
      WRITE : (15) i_main-mwsbk CURRENCY 'IDR', '|',
               (8) i_main-xblnr CENTERED , '|',
              (40) l_text, '|'.
    ELSE.
      WRITE: /     '|',
               (5) i_main-vkbur, '|',
              (20) i_main-zuonr, '|',
                   i_main-fkdat_rl, '|',
                   i_main-fkdat, '|',
                   i_main-kunrg, '|',
              (40) i_main-name_co, '|',
              (20) i_main-stceg, '|',
                   i_main-vatpr, '|',
                   i_main-dudat, '|'.
      IF i_main-fkdat > gs_dpp-datab.
        WRITE : (15) i_main-dpp DECIMALS 0, '|'.
      ELSE.
        WRITE : (15) i_main-netwr CURRENCY 'IDR', '|'.
      ENDIF.
*            (15) i_main-tkwert CURRENCY 'IDR', '|',
      WRITE :              (15) i_main-mwsbk CURRENCY 'IDR', '|',
                     (8) i_main-xblnr CENTERED , '|',
                    (40) l_text, '|'.
    ENDIF.
    IF i_live IS INITIAL.
      i_main-fkdat = i_main-bldat.
      MODIFY i_main TRANSPORTING fkdat.
    ENDIF.
  ENDLOOP.

  LOOP AT i_main WHERE flag1 NE space.
    CLEAR i_live.
    READ TABLE i_live WITH KEY vstel = i_main-vkbur
                               live  = 'X'.
    IF sy-subrc = 0.
      CLEAR i_main-xblnr.
    ENDIF.

    CLEAR l_text.
    IF i_main-flag1 = 'K'.
      CONCATENATE 'Koreksi   ' i_main-zuonr_ref i_main-vbeln_ref i_main-dueyr_ref
        INTO l_text SEPARATED BY '/'.
    ELSEIF i_main-flag1 = 'G'.
      CONCATENATE 'Pengganti ' i_main-zuonr_ref i_main-vbeln_ref i_main-dueyr_ref
        INTO l_text SEPARATED BY '/'.
    ENDIF.

    IF i_main-fkdat < d_datab  AND d_flag = 'X'.
      WRITE: /     '|',
               (5) i_main-vkbur, '|',
              (20) i_main-zuonr, '|',
                   i_main-fkdat, '|',
                   i_main-erdat, '|',
                   i_main-kunrg, '|',
              (40) i_main-name_co, '|',
              (20) i_main-stceg, '|',
                   i_main-vatpr, '|',
                   i_main-dudat, '|'.
      IF i_main-fkdat > gs_dpp-datab.
        WRITE : (15) i_main-dpp DECIMALS 0, '|'.
      ELSE.
        WRITE : (15) i_main-netwr CURRENCY 'IDR', '|'.
      ENDIF.
*            (15) i_main-tkwert CURRENCY 'IDR', '|',
      WRITE : (15) i_main-mwsbk CURRENCY 'IDR', '|',
                     (8) i_main-xblnr CENTERED , '|',
                    (40) l_text, '|'.
    ELSE.
      WRITE: /     '|',
               (5) i_main-vkbur, '|',
              (20) i_main-zuonr, '|',
                   i_main-fkdat_rl, '|',
                   i_main-fkdat, '|',
                   i_main-kunrg, '|',
              (40) i_main-name_co, '|',
              (20) i_main-stceg, '|',
                   i_main-vatpr, '|',
                   i_main-dudat, '|'.
      IF i_main-fkdat > gs_dpp-datab.
        WRITE : (15) i_main-dpp DECIMALS 0, '|'.
      ELSE.
        WRITE : (15) i_main-netwr CURRENCY 'IDR', '|'.
      ENDIF.
*            (15) i_main-tkwert CURRENCY 'IDR', '|',
      WRITE : (15) i_main-mwsbk CURRENCY 'IDR', '|',
               (8) i_main-xblnr CENTERED , '|',
              (40) l_text, '|'.
    ENDIF.
    IF i_live IS INITIAL.
      i_main-fkdat = i_main-bldat.
      MODIFY i_main TRANSPORTING fkdat.
    ENDIF.
  ENDLOOP.

  WRITE sy-uline.

* Check Preview.
  IF p_prev IS INITIAL.

* Write ZFVATO
    lt_zfvato[] = i_main[].
    MODIFY zfvato FROM TABLE lt_zfvato.

    IF sy-subrc = 0 AND NOT i_main[] IS INITIAL.

* Update ZSL_HSALES
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_zsl_hsales
        FROM zsl_hsales
        FOR ALL ENTRIES IN i_main
        WHERE vkorg = i_main-vkorg AND
              vkbur = i_main-vkbur AND
              vbeln = i_main-vbeln1 AND
              account_no = i_main-vbeln AND
              vbtyp = i_main-vbtyp AND
*              budat = i_main-fkdat AND
              stafjk = space.
      IF sy-subrc = 0.
        lt_zsl_hsales-stafjk = 'X'.
        MODIFY lt_zsl_hsales TRANSPORTING stafjk WHERE stafjk = space.
        MODIFY zsl_hsales FROM TABLE lt_zsl_hsales.
      ENDIF.

* Update VAT No
      LOOP AT i_zfvatnr.
        UPDATE zfvatnr SET vatno = i_zfvatnr-vatno
                           vatfr = i_zfvatnr-vatfr
                           vatto = i_zfvatnr-vatto
                           vatpr = i_zfvatnr-vatpr
                           vatdt = i_zfvatnr-vatdt
                           vatcd = i_zfvatnr-vatcd
                           posnr = i_zfvatnr-posnr
                           vatold = i_zfvatnr-vatold
          WHERE vkorg = i_zfvatnr-vkorg AND
                vkbur = i_zfvatnr-vkbur AND
                gjahr = i_zfvatnr-gjahr.
      ENDLOOP.
*      UPDATE zfvatnr SET vatno = v_vatno
*        WHERE vkorg = p_vkorg AND
*              vkbur = '0200'.

* Update ZFVATO ( Koreksi / Pengganti )
      IF i_koreksi[] IS NOT INITIAL.
        CLEAR lt_zfvato. REFRESH lt_zfvato.
        lt_zfvato[] = i_koreksi[].
        MODIFY zfvato FROM TABLE lt_zfvato.
      ENDIF.

* Update ZBIL
      IF i_zbil[] IS NOT INITIAL.
        MODIFY zbil FROM TABLE i_zbil.
      ENDIF.

** Revisi by Budi, Req by SJT 24/05/2010
* Update ZMM_CUST_REC
      DELETE i_zmm_cust_rec WHERE txsts = ' '.
      MODIFY zmm_cust_rec FROM TABLE i_zmm_cust_rec.
** End Revisi by Budi, Req by SJT 24/05/2010

* Realese lock
      PERFORM release_lock.

    ENDIF.

  ENDIF.

ENDFORM.                    " write_table

*&---------------------------------------------------------------------*
*&      Form  write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header.

  DATA: l_period(35),
        l_date1(10),
        l_date2(10),
        l_prev(7).

  WRITE: s_erdat-low TO l_date1,
         s_erdat-high TO l_date2.
  CONCATENATE 'Period' l_date1 'To' l_date2 INTO l_period
        SEPARATED BY space.
  IF NOT p_prev IS INITIAL.
    l_prev = 'Preview'.
  ENDIF.

  WRITE : / 'Date :', sy-datum,
            20(166) 'VAT Out Process PT. Tempo' CENTERED,
            'User :', sy-uname.
  WRITE : / 'Time :', sy-uzeit,
            20(166) l_period CENTERED,
            'Page :', sy-pagno.
  WRITE : /20(166) l_prev CENTERED.

  WRITE sy-uline.
  WRITE: /     '|',
           (5) 'SlOff', '|',
          (20) 'DO No.' CENTERED, '|',
          (10) 'DO Date' CENTERED, '|',
          (10) 'Bill Date' CENTERED, '|',
          (10) 'Customer' CENTERED, '|',
          (40) 'Customer Name' CENTERED, '|',
          (20) 'NPWP No.', '|',
          (20) 'VAT Out No.' CENTERED, '|',
          (10) 'VAT Date.' CENTERED, '|',
*          (15) 'A/R Value' RIGHT-JUSTIFIED, '|',
          (15) 'DPP Value' RIGHT-JUSTIFIED, '|',
          (15) 'PPN Value' RIGHT-JUSTIFIED, '|',
           (8) 'No Kirim' CENTERED, '|',
          (40) 'Keterangan' CENTERED, '|'.
  WRITE sy-uline.

ENDFORM.                    " write_header

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE copy_ok_code INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
ENDMODULE.                 " COPY_OK_CODE  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF p_new = 'X'.
        IF vflag1 = 0.
          zfvatnr-mandt = sy-mandt.
          zfvatnr-vkorg = s2vkorg.
          zfvatnr-vkbur = s2vkbur.
          zfvatnr-vatno = s2vatno.
          zfvatnr-vatfr = s2vatfr.
          zfvatnr-vatto = s2vatto.
          zfvatnr-vatpr = s2vatpr.
          zfvatnr-vatdt = s2vatdt.
          zfvatnr-gjahr = s2gjahr.
          MODIFY zfvatnr.
        ELSE.
          UPDATE zfvatnr SET
            vatno = s2vatno
            vatfr = s2vatfr
            vatto = s2vatto
            vatpr = s2vatpr
            vatdt = s2vatdt
            gjahr = s2gjahr
            WHERE vkorg = p_vkorg AND
                  vkbur = p_vatbr AND
                  gjahr = p_vatyr.
        ENDIF.
      ELSE.
        IF vflag1 = 0.
          zfvatnr-mandt = sy-mandt.
          zfvatnr-vkorg = s2vkorg.
          zfvatnr-vkbur = s2vkbur.
          zfvatnr-vatno = s2vatno.
          zfvatnr-vatfr = s2vatfr.
          zfvatnr-vatto = s2vatto.
          zfvatnr-vatpr = s2vatpr.
          zfvatnr-vatdt = s2vatdt.
          zfvatnr-gjahr = s2gjahr.
          MODIFY zfvatnr.
        ELSE.
          UPDATE zfvatnr SET
            vatno = s2vatno
            vatfr = s2vatfr
            vatto = s2vatto
            vatpr = s2vatpr
            vatdt = s2vatdt
            gjahr = s2gjahr
            WHERE vkorg = p_vkorg AND
                  vkbur = p_vkbur.
        ENDIF.
      ENDIF.
      PERFORM release_lock.
      COMMIT WORK.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'STATUS_0300'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF s3vatnm NE space OR s3vattl NE space.
        zfvatnm-mandt = sy-mandt.
        zfvatnm-vkorg = s3vkorg.
        zfvatnm-vkbur = s3vkbur.
        zfvatnm-vtart = 'SD'.
        zfvatnm-vatnm = s3vatnm.
        zfvatnm-vattl = s3vattl.
        zfvatnm-object1 = s3object1.
        zfvatnm-vatnm2 = s3vatnm2.
        zfvatnm-vattl2 = s3vattl2.
        zfvatnm-object2 = s3object2.
        zfvatnm-vatnm3 = s3vatnm3.
        zfvatnm-vattl3 = s3vattl3.
        zfvatnm-object3 = s3object3.
        MODIFY zfvatnm.
      ELSE.
        MESSAGE i002.
      ENDIF.
      COMMIT WORK.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Form  process_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_download.

  DATA: l_count TYPE i,
        l_dpp   LIKE zfvato-netwr,
        l_ppn   LIKE zfvato-mwsbk,
        l_date1 LIKE zfvato-erdat,
        l_date2 LIKE zfvato-erdat.
  RANGES:   l_nokir FOR p_nokir.

  CONCATENATE p_year '01' '01' INTO l_date1.
  CONCATENATE p_year '12' '31' INTO l_date2.

* Get For Download
* jika p_nokir untuk nomor urut diisi dengan 00 maka diambil semua untuk bulan itu
* contoh jika p_nokir(nomor pengiriman) diisi dengan '0200' artinya ambil semua pengiriman di bulan 02
* '00' artinya semua.

  IF p_nokir+2(2) = '00'.
    l_nokir-low = p_nokir.
    l_nokir-high = p_nokir.
    l_nokir-high+2(2) = '99'.
    l_nokir-sign = 'I'.
    l_nokir-option = 'BT'.
    APPEND l_nokir.
    SELECT vkorg vkbur vatno vbeln zuonr vatpr name_co
           dudat dueyr duemm netwr mwsbk sortl a~stceg
      INTO CORRESPONDING FIELDS OF TABLE i_downvato
      FROM zfvato AS a JOIN kna1 AS b ON a~kunrg = b~kunnr
      WHERE vkorg = p_vkorg2 AND
            vkbur = p_vkbur2 AND
            a~erdat BETWEEN l_date1 AND l_date2 AND
*              dueyr = p_year   AND
*              duemm = p_month  AND
            xblnr IN l_nokir  AND
*              flag1 = space.
            fl_cancel = space.
  ELSE.
    SELECT vkorg vkbur vatno vbeln zuonr vatpr name_co
           dudat dueyr duemm netwr mwsbk sortl a~stceg
      INTO CORRESPONDING FIELDS OF TABLE i_downvato
      FROM zfvato AS a JOIN kna1 AS b ON a~kunrg = b~kunnr
      WHERE vkorg = p_vkorg2 AND
            vkbur = p_vkbur2 AND
            a~erdat BETWEEN l_date1 AND l_date2 AND
*            dueyr = p_year   AND
*            duemm = p_month  AND
            xblnr = p_nokir  AND
*            flag1 = space.
            fl_cancel = space.

  ENDIF.


  IF i_downvato[] IS INITIAL.
    MESSAGE i000(zf) WITH 'No Data'.
    STOP.
  ENDIF.

  DO 17 TIMES.
    CLEAR i_down_field.
    ADD 1 TO l_count.
    CASE l_count.
      WHEN '1'.
        i_down_field-txt_field = 'BRCOD'.
      WHEN '2'.
        i_down_field-txt_field = 'VBELN'.
      WHEN '3'.
        i_down_field-txt_field = 'SEQTYP'.
      WHEN '4'.
        i_down_field-txt_field = 'SEQNR'.
      WHEN '5'.
        i_down_field-txt_field = 'OUTGR'.
      WHEN '6'.
        i_down_field-txt_field = 'OUTCD'.
      WHEN '7'.
        i_down_field-txt_field = 'SERIPJK'.
      WHEN '8'.
        i_down_field-txt_field = 'NOPJK'.
      WHEN '9'.
        i_down_field-txt_field = 'TGLPJK'.
      WHEN '10'.
        i_down_field-txt_field = 'TGLPRS'.
      WHEN '11'.
        i_down_field-txt_field = 'JAMPRS'.
      WHEN '12'.
        i_down_field-txt_field = 'USERPRS'.
      WHEN '13'.
        i_down_field-txt_field = 'DPP'.
      WHEN '14'.
        i_down_field-txt_field = 'PPN'.
      WHEN '15'.
        i_down_field-txt_field = 'KETR'.
      WHEN '16'.
        i_down_field-txt_field = 'OUTNM'.
      WHEN '17'.
        i_down_field-txt_field = 'NPWP'.
    ENDCASE.
    APPEND i_down_field.
  ENDDO.

  LOOP AT i_downvato.
    CLEAR: l_dpp,l_ppn,v_filename.

    PERFORM f_tax_calc USING i_downvato-dudat i_downvato-netwr 'A'
                       CHANGING l_dpp.

*    l_dpp = ( i_downvato-netwr * 100 ) / ( 110 / 100 ).

    l_ppn = i_downvato-mwsbk * 100.
    i_download-brcod = i_downvato-zuonr+1(1).
    i_download-vbeln = i_downvato-vbeln.
    i_download-seqtyp = i_downvato-zuonr+2(1).
    i_download-seqnr = i_downvato-zuonr+3(6).
    i_download-outgr = i_downvato-sortl+2(1).
    i_download-outcd = i_downvato-sortl+3(6).
    i_download-seripjk = i_downvato-vatpr(10).
    IF i_downvato-vatno IS INITIAL.
      CONCATENATE i_downvato-zuonr+2(1) '-' i_downvato-zuonr+3(6)
          INTO i_download-nopjk.
    ELSE.
      IF i_downvato GE '20070101'.
        i_download-nopjk = i_downvato-vatpr+10(10).
      ELSE.
        i_download-nopjk = i_downvato-vatno.
      ENDIF.
    ENDIF.
    i_download-tglpjk = i_downvato-dudat.
    i_download-tglprs = sy-datum.
    i_download-jamprs = sy-uzeit.
    i_download-userprs = sy-uname.
    i_download-dpp = l_dpp.
    i_download-ppn = l_ppn.
    i_download-outnm = i_downvato-name_co.
    i_download-npwp = i_downvato-stceg.
*{   REPLACE        P01K910438                                        1
*\    AT LAST.
    "Start SOH: Shell SCI Adjustment 20240222 RZL
    AT LAST.                                             "#EC CI_SORTED
      "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
      CONCATENATE 'PPN' i_download-brcod p_nokir(4) '.DBF'
            INTO v_filename.
    ENDAT.
    APPEND i_download. CLEAR i_download.
  ENDLOOP.

ENDFORM.                    " process_download

*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_file.

  DATA: lt_zfvato LIKE zfvato OCCURS 0 WITH HEADER LINE.

* Download
  CONCATENATE p_path v_filename INTO v_filename.
*Begin remark Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
*      filename                = v_filename
*      filetype                = 'DBF'
*    TABLES
*      data_tab                = i_download
*      fieldnames              = i_down_field
*    EXCEPTIONS
*      file_open_error         = 1
*      file_write_error        = 2
*      invalid_filesize        = 3
*      invalid_type            = 4
*      no_batch                = 5
*      unknown_error           = 6
*      invalid_table_width     = 7
*      gui_refuse_filetransfer = 8
*      customer_error          = 9.
*End remark Unicode conversion - DEVK965554

*Begin insert Unicode conversion - DEVK965554
*27.02.2020 - SOL_FELIX
  DATA: lv_filename TYPE string.
  CLEAR lv_filename.
  lv_filename = v_filename.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = 'DBF'
      fieldnames              = i_down_field[]
    CHANGING
      data_tab                = i_download[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
*End insert Unicode conversion - DEVK965554

  IF sy-subrc = 0.
    IF p_nokir+2(2) NE '00'.
* Update Flag ZFVATO
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_zfvato
        FROM zfvato
        FOR ALL ENTRIES IN i_downvato
        WHERE vkorg = i_downvato-vkorg AND
              vkbur = i_downvato-vkbur AND
              vatno = i_downvato-vatno AND
              vbeln = i_downvato-vbeln AND
              zuonr = i_downvato-zuonr AND
              dueyr = i_downvato-dueyr AND
              duemm = i_downvato-duemm AND
              fl_cancel = space.
*              flag1 = space.

      lt_zfvato-flag1 = 'D'.
      MODIFY lt_zfvato TRANSPORTING flag1 WHERE flag1 NE 'D'.
      MODIFY zfvato FROM TABLE lt_zfvato.
    ENDIF.

    MESSAGE s000(zf) WITH 'Download Successfully'.

  ENDIF.

ENDFORM.                    " download_file

*&---------------------------------------------------------------------*
*&      Form  f_get_vat_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MAIN_DUDAT  text
*      <--P_V_VATTO  text
*      <--P_V_VATNO  text
*      <--P_V_VATPR  text
*----------------------------------------------------------------------*
FORM f_get_vat_number USING    p_i_main_dudat
                               p_i_main_vkbur
                               p_i_main_gform
                               p_i_main-flkor
                               p_i_main-zuonr_ref
                               p_i_main-vbeln_ref
                      CHANGING p_v_vatto
                               p_v_vatno
                               p_v_vatold
                               p_v_vatpr
                               p_i_main_vatbr
                               p_i_main_vatno
                               p_i_main_dueyr_ref
                               p_w_zfvatnr_dtl.

  DATA: lt_vatpr(20),
        ld_posnr     LIKE zfvatnr-posnr,
        ld_vatpr     LIKE zfvatnr-vatpr,
        ld_length    TYPE i,
        ld_variant   TYPE i.

  CLEAR: i_zfvatnr,i_zfvattrn,i_zfvatnr_dtl,ld_vatpr,ld_length,ld_variant.
  IF p_i_main_dudat GE '20070101'.
    READ TABLE i_zfvattrn WITH KEY vkorg = p_vkorg
                                   vkbur = p_i_main_vkbur
                                   gform = p_i_main_gform.
    READ TABLE i_zfvatnr WITH KEY vkorg = p_vkorg
                                  vkbur = i_zfvattrn-vatbr
                                  gjahr = p_i_main_dudat(4).
    p_i_main_vatbr = i_zfvattrn-vatbr.
    p_v_vatto = i_zfvatnr-vatto.
    p_v_vatno = i_zfvatnr-vatno.
    p_v_vatold = i_zfvatnr-vatold.

*  Rev. by Budi 15/03/2013 Req. by SJT
    IF v_flg_pajak2013 IS NOT INITIAL AND
       v_dat_pajak2013 LE p_i_main_dudat.

      IF p_i_main-flkor IS NOT INITIAL.
        SELECT SINGLE vatpr vatno dueyr
          INTO (p_v_vatpr,p_i_main_vatno,p_i_main_dueyr_ref)
          FROM zfvato
          WHERE vkorg = p_vkorg         AND
                vkbur = p_i_main_vkbur  AND
                zuonr = p_i_main-zuonr_ref  AND
                vbeln = p_i_main-vbeln_ref.

      ELSE.
        IF p_v_vatno GE p_v_vatto.
          ld_posnr = i_zfvatnr-posnr + 10.
          CLEAR i_zfvatnr_dtl.
          READ TABLE i_zfvatnr_dtl WITH KEY vkorg = p_vkorg
                                            vkbur = i_zfvattrn-vatbr
                                            gjahr = p_i_main_dudat(4)
                                            posnr = ld_posnr.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING i_zfvatnr_dtl TO p_w_zfvatnr_dtl.
            p_v_vatto = i_zfvatnr_dtl-vatto.
            p_v_vatno = i_zfvatnr_dtl-vatfr.
            ld_vatpr = i_zfvatnr_dtl-vatpr.
            i_zfvatnr-vatcd = i_zfvatnr_dtl-vatcd.
          ELSE.
            p_v_vatno = i_zfvatnr-vatno + 1.
            MESSAGE i007.
            EXIT.
          ENDIF.
        ELSE.
          p_v_vatno = i_zfvatnr-vatno + 1.
          ld_vatpr = i_zfvatnr-vatpr.
        ENDIF.

        IF p_bahan IS NOT INITIAL.
          i_zfvattrn-vattrn = '08'.
        ELSE.
          IF i_zfvattrn-vattrn = '01'.
            IF p_i_main_dudat > gs_dpp-datab.
              i_zfvattrn-vattrn = '04'.
            ENDIF.
          ENDIF.
        ENDIF.

        IF ld_vatpr IS NOT INITIAL.
          ld_length = strlen( ld_vatpr ).
          ld_variant = 8 - ld_length.
          CONCATENATE i_zfvattrn-vattrn '0' i_zfvatnr-vatcd
                      p_i_main_dudat+2(2) ld_vatpr p_v_vatno+ld_length(ld_variant)
                 INTO lt_vatpr.
        ELSE.
          CONCATENATE i_zfvattrn-vattrn '0' i_zfvatnr-vatcd
                      p_i_main_dudat+2(2) p_v_vatno
                 INTO lt_vatpr.
        ENDIF.
        WRITE lt_vatpr TO p_v_vatpr USING EDIT MASK '___.___-__.________'.
      ENDIF.

    ELSE.
      p_v_vatold = i_zfvatnr-vatold + 1.
      CONCATENATE i_zfvattrn-vattrn '0' i_zfvattrn-vatbr
                  p_i_main_dudat+2(2) p_v_vatold INTO lt_vatpr.
      WRITE lt_vatpr TO p_v_vatpr USING EDIT MASK '___.___-__.________'.
    ENDIF.
*  End Rev. by Budi 15/03/2013 Req. by SJT

  ELSE.
    READ TABLE i_zfvatnr WITH KEY vkorg = p_vkorg
                                  vkbur = '0200'.
    p_v_vatto = i_zfvatnr-vatto.
    p_v_vatno = i_zfvatnr-vatno + 1.
    CONCATENATE i_zfvatnr-vatpr p_v_vatno INTO lt_vatpr.
    WRITE lt_vatpr TO p_v_vatpr.
  ENDIF.

ENDFORM.                    " f_get_vat_number

*&---------------------------------------------------------------------*
*&      Form  faktur_pengganti
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM faktur_pengganti CHANGING p_l_flag1
                               p_l_vatpr
                               p_l_vatno
                               p_l_vbeln_ref
                               p_l_zuonr_ref
                               p_l_dueyr_ref.

  DATA: lw_hsales LIKE zsl_hsales,
        lw_fvato  LIKE zfvato.

  RANGES: lr_gjahr FOR zsl_hsales-gjahr.

  CLEAR: lr_gjahr. REFRESH: lr_gjahr.
  lr_gjahr-sign = 'I'.
  lr_gjahr-option = 'EQ'.
  lr_gjahr-low = i_legacy-gjahr.
  APPEND lr_gjahr.
  lr_gjahr-sign = 'I'.
  lr_gjahr-option = 'EQ'.
  lr_gjahr-low = i_legacy-gjahr - 1.
  APPEND lr_gjahr.

  SELECT SINGLE * INTO lw_hsales FROM zsl_hsales
    WHERE vbeln = i_legacy-sonr  AND
          vkbur = i_legacy-vkbur AND
          vkorg = i_legacy-vkorg AND
*          gjahr = i_legacy-gjahr.
          gjahr IN lr_gjahr.

  IF sy-subrc IS INITIAL.
    SELECT SINGLE * INTO lw_fvato FROM zfvato
      WHERE vkorg = lw_hsales-vkorg  AND
            vkbur = lw_hsales-vkbur  AND
*            vbeln = lw_hsales-acct_ref AND
            zuonr = lw_hsales-sonr   AND
*            gjahr = lw_hsales-gjahr  AND
            gjahr IN lr_gjahr  AND
            vtart = 'SD'.

    IF sy-subrc IS INITIAL.
      IF lw_fvato-dudat(6) = i_main-dudat(6).
        p_l_flag1 = 'K'.
        IF lw_fvato-vatpr IS NOT INITIAL.
          p_l_vatno = lw_fvato-vatno.
          p_l_vatpr = lw_fvato-vatpr.
        ENDIF.
      ELSE.
        p_l_flag1 = 'G'.
      ENDIF.
      p_l_vbeln_ref = lw_fvato-vbeln.
      p_l_zuonr_ref = lw_fvato-zuonr.
      p_l_dueyr_ref = lw_fvato-dueyr.

      lw_fvato-fl_cancel = 'X'.
      i_koreksi = lw_fvato.
      APPEND i_koreksi.
    ELSE.
      CLEAR: p_l_flag1, p_l_vatpr.
    ENDIF.

  ENDIF.

ENDFORM.                    " faktur_pengganti

*&---------------------------------------------------------------------*
*&      Form  faktur_pengganti_sap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM faktur_pengganti_sap USING    fu_zbil LIKE i_zbil
                          CHANGING p_l_flag1
                                   p_l_vatpr
                                   p_l_vatno
                                   p_l_vbeln_ref
                                   p_l_zuonr_ref
                                   p_l_dueyr_ref.

  DATA: lw_vbrk  LIKE vbrk,
        lw_fvato LIKE zfvato.

  SELECT SINGLE * INTO lw_vbrk FROM vbrk
    WHERE vbeln = fu_zbil-bilno.

  SELECT SINGLE * INTO lw_fvato FROM zfvato
    WHERE vkorg = i_main-vkorg  AND
          vkbur = i_main-vkbur  AND
          zuonr = lw_vbrk-zuonr AND
          vbeln = lw_vbrk-vbeln AND
          vtart = 'SD'.

  IF sy-subrc IS INITIAL.

    IF lw_fvato-dudat(6) = i_main-dudat(6).
      p_l_flag1 = 'K'.
      IF lw_fvato-vatpr IS NOT INITIAL.
        p_l_vatno = lw_fvato-vatno.
        p_l_vatpr = lw_fvato-vatpr.
      ENDIF.
    ELSE.
      p_l_flag1 = 'G'.
    ENDIF.

    p_l_vbeln_ref = lw_fvato-vbeln.
    p_l_zuonr_ref = lw_fvato-zuonr.
    p_l_dueyr_ref = lw_fvato-dueyr.

    i_zbil-dono_gnt    = fu_zbil-vgbel.
    i_zbil-vbeln_gnt   = fu_zbil-vbeln.
    i_zbil-cityc_ganti = lw_fvato-cityc.
    i_zbil-vatno_ganti = p_l_vatpr.
    MODIFY i_zbil TRANSPORTING dono_gnt vbeln_gnt cityc_ganti vatno_ganti
                  WHERE vkorg = fu_zbil-vkorg AND
                        vkbur = fu_zbil-vkbur AND
                        bilno = fu_zbil-bilno.

    lw_fvato-fl_cancel = 'X'.
    i_koreksi = lw_fvato.
    APPEND i_koreksi.

  ELSE.

    CLEAR: p_l_flag1, p_l_vatpr.

  ENDIF.

ENDFORM.                    " faktur_pengganti_sap

*************************************************************
FORM f_dynpro USING dynbegin name value.
*************************************************************
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_GET_FLAG_ZPROJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_flag_zproject .
  CLEAR: v_dat_pajak2013,v_flg_pajak2013.
  SELECT SINGLE datab flag INTO (v_dat_pajak2013, v_flg_pajak2013)
    FROM zproject WHERE name = 'PAJAK2013'.
ENDFORM.                    " F_GET_FLAG_ZPROJECT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0210 OUTPUT.
  SET PF-STATUS 'STATUS_210'.
  SET TITLEBAR '210'.
  DESCRIBE TABLE gt_vdata LINES fill.
  input-lines = fill.
ENDMODULE.                 " STATUS_0210  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  READ TABLE gt_vdata INTO gt_vdata1 INDEX input-current_line.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control INPUT.
  MODIFY gt_vdata FROM gt_vdata1 INDEX input-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0210 INPUT.
  save_ok = ok_code.
  CLEAR: ok_code.
  CASE save_ok.
    WHEN 'ENTER'.
      PERFORM f_validate_data.
    WHEN 'SAVE'.
      PERFORM f_validate_data.
      PERFORM f_save_data.
    WHEN '&DEL'.
      PERFORM fcode_delete_row USING  'INPUT'
                                      'GT_VDATA'
                                      'FLAG'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0210  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SCREEN_210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_screen_210 .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_vdata
    FROM zfvatnr_dtl
    WHERE vkorg = p_vkorg
      AND vkbur = p_vatbr
      AND gjahr = p_vatyr.

  DO 50 TIMES.
    APPEND INITIAL LINE TO gt_vdata.
  ENDDO.
ENDFORM.                    " F_INIT_SCREEN_210

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.
  DATA l_table_delete     LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      APPEND INITIAL LINE TO <table>.
*      IF sy-subrc = 0.
*        <tc>-lines = <tc>-lines - 1.
*      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_data .
  DATA: ld_posnr       LIKE gt_vdata-posnr,
        ld_zfvatnr     LIKE zfvatnr,
        ld_s2vatno     LIKE s2vatno,
        ld_interval(1).

  CHECK gw_vdata IS NOT INITIAL.
  CLEAR ld_s2vatno. ld_s2vatno = s2vatno + 1.

  DELETE gt_vdata WHERE vatfr = '00000000' AND
                        vatto = '00000000' AND
                        vatpr = space      AND
                        vatdt = '00000000' AND
                        vatcd = space.
  SORT gt_vdata BY posnr.
  LOOP AT gt_vdata.
*    ADD 10 TO ld_posnr.
    gt_vdata-vkorg = s2vkorg.
    gt_vdata-vkbur = s2vkbur.
    gt_vdata-gjahr = s2gjahr.
*    gt_vdata-posnr = ld_posnr.
    MODIFY gt_vdata TRANSPORTING vkorg vkbur gjahr posnr.
    CLEAR gt_vdata.
  ENDLOOP.

  IF gt_vdata[] IS NOT INITIAL.
    IF vflag1 = 0.
      CLEAR gt_vdata.
      READ TABLE gt_vdata INDEX 1.
      ld_zfvatnr-vkorg = s2vkorg.
      ld_zfvatnr-vkbur = s2vkbur.
      ld_zfvatnr-gjahr = s2gjahr.
      ld_zfvatnr-vatno = s2vatno.
      ld_zfvatnr-vatold = s2vatold.
      ld_zfvatnr-vatfr = gt_vdata-vatfr.
      ld_zfvatnr-vatto = gt_vdata-vatto.
      ld_zfvatnr-vatpr = gt_vdata-vatpr.
      ld_zfvatnr-vatdt = gt_vdata-vatdt.
      ld_zfvatnr-vatcd = gt_vdata-vatcd.
      ld_zfvatnr-posnr = gt_vdata-posnr.
      MODIFY zfvatnr FROM ld_zfvatnr.
    ELSE.
      CLEAR ld_interval.
      LOOP AT gt_vdata.
        IF gt_vdata-vatfr LE s2vatno AND
           gt_vdata-vatto GE s2vatno.
          ld_interval = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF ld_interval IS INITIAL.
        CLEAR gt_vdata.
        READ TABLE gt_vdata INDEX 1.
        UPDATE zfvatnr SET vatno = s2vatno
                           vatold = s2vatold
                           vatfr = s2vatno
                           vatto = s2vatno
                           vatpr = gt_vdata-vatpr
                           vatdt = gt_vdata-vatdt
                           vatcd = gt_vdata-vatcd
                           posnr = '000000'
                       WHERE vkorg = s2vkorg AND
                             vkbur = s2vkbur AND
                             gjahr = s2gjahr.
      ELSE.
        UPDATE zfvatnr SET vatno = s2vatno
                           vatold = s2vatold
                           vatfr = gt_vdata-vatfr
                           vatto = gt_vdata-vatto
                           vatpr = gt_vdata-vatpr
                           vatdt = gt_vdata-vatdt
                           vatcd = gt_vdata-vatcd
                           posnr = gt_vdata-posnr
                       WHERE vkorg = s2vkorg AND
                             vkbur = s2vkbur AND
                             gjahr = s2gjahr.
      ENDIF.

      DELETE FROM zfvatnr_dtl WHERE vkorg = s2vkorg AND
                                    vkbur = s2vkbur AND
                                    gjahr = s2gjahr.
    ENDIF.
    MODIFY zfvatnr_dtl FROM TABLE gt_vdata.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data .
  DATA: ld_vatfr LIKE gt_vdata-vatfr.

  CLEAR gw_vdata.
  LOOP AT gt_vdata.
    CLEAR ld_vatfr.
    ld_vatfr = gt_vdata-vatfr - 1.
    IF ld_vatfr LE s2vatno AND
       gt_vdata-vatto GE s2vatno.
      MOVE-CORRESPONDING gt_vdata TO gw_vdata.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gw_vdata IS INITIAL.
    MESSAGE 'Interval number not found' TYPE 'I'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FAKTUR_PENGGANTI_2013
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FC_MAIN  text
*----------------------------------------------------------------------*
FORM f_faktur_pengganti_2013 TABLES    ft_r_vkbursap
                                       ft_r_vkburleg
                             CHANGING  fc_main LIKE i_main
                                       fc_vat_awal.

  DATA: ld_vbelv       LIKE zfvato-vbelv,
        ld_vgbel_ganti LIKE vbak-vgbel,
        ld_zuonr_ganti LIKE vbak-zuonr,
        ld_vgbel_asal  LIKE vbak-vgbel,
        ld_zuonr_asal  LIKE vbak-zuonr,
        lw_zfvato_asal LIKE zfvato,
        ld_type(1)     TYPE n.

  CLEAR: ld_vbelv,ld_vgbel_ganti,ld_zuonr_ganti,ld_vgbel_asal,
         ld_zuonr_asal,lw_zfvato_asal,ld_type,i_zfvattrn,i_zfvatnr.

  READ TABLE i_zfvattrn WITH KEY vkorg = fc_main-vkorg
                                 vkbur = fc_main-vkbur
                                 gform = fc_main-gform.
  READ TABLE i_zfvatnr WITH KEY vkorg = fc_main-vkorg
                                vkbur = i_zfvattrn-vatbr
                                gjahr = fc_main-dudat(4).

  IF fc_main-vkbur IN ft_r_vkbursap AND
     ft_r_vkbursap[] IS NOT INITIAL.
    SELECT SINGLE vgbel zuonr
      INTO (ld_vgbel_ganti,ld_zuonr_ganti)
      FROM vbak WHERE vbeln = fc_main-vbelv.
    IF sy-subrc = 0.
      SELECT SINGLE vgbel zuonr
        INTO (ld_vgbel_asal,ld_zuonr_asal)
        FROM vbak WHERE vbeln = ld_vgbel_ganti.
      IF sy-subrc = 0.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF lw_zfvato_asal
          FROM zfvato WHERE vkorg = fc_main-vkorg AND
                            vkbur = fc_main-vkbur AND
                            vbeln = ld_vgbel_asal AND
                            zuonr = ld_zuonr_asal.
        IF sy-subrc = 0.
          fc_vat_awal = '1'.
          IF v_flg_pajak2013 IS NOT INITIAL AND
             v_dat_pajak2013 LE lw_zfvato_asal-dudat.
            fc_main-vatno = lw_zfvato_asal-vatno.
            fc_main-vatpr = lw_zfvato_asal-vatpr.
            ld_type = fc_main-vatpr+2(1).
            ld_type = ld_type + 1.
            fc_main-vatpr+2(1) = ld_type.
          ELSE.
            i_zfvatnr-vatold = i_zfvatnr-vatold + 1.
            fc_main-vatno = i_zfvatnr-vatold.
            MODIFY i_zfvatnr TRANSPORTING vatold
                             WHERE vkorg = fc_main-vkorg AND
                                   vkbur = fc_main-vatbr AND
                                   gjahr = fc_main-dudat(4).
            fc_main-vatpr = lw_zfvato_asal-vatpr.
            ld_type = fc_main-vatpr+2(1).
            ld_type = ld_type + 1.
            fc_main-vatpr+2(1) = ld_type.
            fc_main-vatpr+8(2) = fc_main-dudat+2(2).
            fc_main-vatpr+11(8) = fc_main-vatno.
          ENDIF.
        ELSE.
          fc_vat_awal = '0'.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSEIF fc_main-vkbur IN ft_r_vkburleg AND
         ft_r_vkburleg[] IS NOT INITIAL.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF lw_zfvato_asal
      FROM zfvato WHERE vkorg = fc_main-vkorg AND
                        vkbur = fc_main-vkbur AND
                        vbeln = fc_main-vbeln_ref AND
                        zuonr = fc_main-zuonr_ref.
    IF sy-subrc = 0.
      fc_vat_awal = '1'.
      IF v_flg_pajak2013 IS NOT INITIAL AND
         v_dat_pajak2013 LE lw_zfvato_asal-dudat.
        fc_main-vatno = lw_zfvato_asal-vatno.
        fc_main-vatpr = lw_zfvato_asal-vatpr.
        ld_type = fc_main-vatpr+2(1).
        ld_type = ld_type + 1.
        fc_main-vatpr+2(1) = ld_type.
      ELSE.
        i_zfvatnr-vatold = i_zfvatnr-vatold + 1.
        fc_main-vatno = i_zfvatnr-vatold.
        MODIFY i_zfvatnr TRANSPORTING vatold
                         WHERE vkorg = fc_main-vkorg AND
                               vkbur = fc_main-vatbr AND
                               gjahr = fc_main-dudat(4).
        fc_main-vatpr = lw_zfvato_asal-vatpr.
        ld_type = fc_main-vatpr+2(1).
        ld_type = ld_type + 1.
        fc_main-vatpr+2(1) = ld_type.
        fc_main-vatpr+8(2) = fc_main-dudat+2(2).
        fc_main-vatpr+11(8) = fc_main-vatno.
      ENDIF.
    ELSE.
      fc_vat_awal = '0'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_FAKTUR_PENGGANTI_2013

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VAT_DATE
*&---------------------------------------------------------------------*
FORM f_check_vat_date  USING    fu_gjahr
                       CHANGING fr_dudat LIKE r_dudat.

  DATA : lv_subrc TYPE sy-subrc,
         lv_dudat TYPE datum,
         wa_dudat LIKE LINE OF s_dudat,
         lr_datum TYPE RANGE OF datum,
         wa_vat   LIKE zfvatnr_dtl,
         lv_posnr TYPE posnr.

  lv_dudat  = s_dudat-low.
  IF s_dudat-high IS INITIAL.
    s_dudat-high = s_dudat-low.
  ENDIF.
  WHILE lv_subrc IS INITIAL.
    wa_dudat-low     = lv_dudat.
    wa_dudat-sign    = 'I'.
    wa_dudat-option  = 'EQ'.
    APPEND wa_dudat TO fr_dudat.
    IF lv_dudat EQ s_dudat-high.
      lv_subrc = 4.
    ENDIF.
    ADD 1 TO lv_dudat.
  ENDWHILE.

  READ TABLE i_zfvatnr WITH KEY vkorg = p_vkorg
                                gjahr = fu_gjahr.
  IF sy-subrc = 0.
    lv_posnr  = i_zfvatnr-posnr.
    IF i_zfvatnr-vatno >= i_zfvatnr-vatto.
      lv_posnr = lv_posnr + 10.
    ENDIF.
  ENDIF.

  CLEAR wa_dudat.
  LOOP AT i_zfvatnr_dtl INTO  wa_vat
                        WHERE vkorg EQ p_vkorg
                          AND gjahr EQ fu_gjahr
                          AND posnr EQ lv_posnr.
    IF wa_vat-validfr IS NOT INITIAL AND
      wa_vat-validto IS NOT INITIAL.
      wa_dudat-low      = wa_vat-validfr.
      wa_dudat-high     = wa_vat-validto.
      wa_dudat-sign     = 'I'.
      wa_dudat-option   = 'BT'.
      APPEND wa_dudat TO lr_datum.
    ENDIF.
  ENDLOOP.

  IF lr_datum[] IS NOT INITIAL.
    LOOP AT fr_dudat INTO wa_dudat.
      IF wa_dudat-low IN lr_datum.
        CONTINUE.
      ELSE.
        DELETE fr_dudat.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT fr_dudat INTO wa_dudat.
      DELETE fr_dudat.
    ENDLOOP.
*    fr_dudat[]  = s_dudat[].
  ENDIF.
ENDFORM.                    " F_CHECK_VAT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_FILENAME_F4
*&---------------------------------------------------------------------*
FORM f_filename_f4  CHANGING fc_filename.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
    IMPORTING
      file_name     = fc_filename.
ENDFORM.                    " F_FILENAME_F4

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILE_UPLOAD
*&---------------------------------------------------------------------*
FORM f_get_file_upload .
  DATA : filename   TYPE localfile.

  filename  = pa_flnm1.

  REFRESH i_excel. CLEAR i_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT i_excel BY row col.
  LOOP AT i_excel.
    CASE i_excel-col.
      WHEN '0001'.
        wa_record-vkorg   = i_excel-value.
      WHEN '0002'.
        wa_record-vkbur   = i_excel-value.
      WHEN '0003'.
        PERFORM f_convert_value USING i_excel-value
                                CHANGING wa_record-vbeln.
      WHEN '0004'.
        wa_record-zuonr   = i_excel-value.
      WHEN '0005'.
        wa_record-dueyr   = i_excel-value.
      WHEN '0006'.
        wa_record-name_co   = i_excel-value.
      WHEN '0007'.
        wa_record-str_suppl1   = i_excel-value.
      WHEN '0008'.
        wa_record-str_suppl2   = i_excel-value.
      WHEN '0009'.
        wa_record-stras   = i_excel-value.
      WHEN '0010'.
        wa_record-cityc   = i_excel-value.
      WHEN '0011'.
        wa_record-stceg   = i_excel-value.
    ENDCASE.
    AT END OF row.
      APPEND wa_record TO gt_record.
      SHIFT wa_record-vbeln LEFT DELETING LEADING '0'.
      APPEND wa_record TO gt_temp.
      CLEAR: wa_record.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_GET_FILE_UPLOAD

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_VALUE
*&---------------------------------------------------------------------*
FORM f_convert_value  USING    fu_value
                      CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_CONVERT_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv  TABLES   ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event  TABLES   ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    " F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
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
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '',
    'VKORG' 'ZFVATO' 'VKORG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFVATO' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VBELN' 'ZFVATO' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUONR' 'ZFVATO' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DUEYR' 'ZFVATO' 'DUEYR' '' '' 'Year' '' '' '' '' '' '' '' '' '' '',
    'NAME_CO' 'ZFVATO' 'NAME_CO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STR_SUPPL1' 'ZFVATO' 'STR_SUPPL1' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STR_SUPPL2' 'ZFVATO' 'STR_SUPPL2' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STRAS' 'ZFVATO' 'STRAS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CITYC' 'ZFVATO' 'CITYC' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'STCEG' 'ZFVATO' 'STCEG' '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'MATKL'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
**  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
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
ENDFORM.                    " F_CLEAR_ALV_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
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
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'TOEXECUTE'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
      MESSAGE s000(zab) WITH 'Data already upload'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries .
  DATA : lt_record LIKE gt_record OCCURS 0 WITH HEADER LINE.

  lt_record[] = gt_record[].
  DELETE lt_record WHERE icon = icon_led_red.

  LOOP AT lt_record.
    UPDATE zfvato   SET name_co = lt_record-name_co
                        str_suppl1 = lt_record-str_suppl1
                        str_suppl2 = lt_record-str_suppl2
                        stras = lt_record-stras
                        cityc = lt_record-cityc
                        stceg = lt_record-stceg
                  WHERE vkorg	= lt_record-vkorg
                    AND vkbur	= lt_record-vkbur
                    AND vbeln = lt_record-vbeln
                    AND zuonr	= lt_record-zuonr
                    AND dueyr = lt_record-dueyr.
    IF sy-subrc <> 0.
      SHIFT lt_record-vbeln LEFT DELETING LEADING '0'.
      UPDATE zfvato   SET name_co = lt_record-name_co
                          str_suppl1 = lt_record-str_suppl1
                          str_suppl2 = lt_record-str_suppl2
                          stras = lt_record-stras
                          cityc = lt_record-cityc
                          stceg = lt_record-stceg
                    WHERE vkorg	= lt_record-vkorg
                      AND vkbur	= lt_record-vkbur
                      AND vbeln = lt_record-vbeln
                      AND zuonr	= lt_record-zuonr
                      AND dueyr = lt_record-dueyr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA_UPLOAD
*&---------------------------------------------------------------------*
FORM f_validate_data_upload .
  DATA : BEGIN OF lt_zfvato OCCURS 0,
           vkorg TYPE vkorg,
           vkbur TYPE vkbur,
           vatno TYPE zvano,
           vbeln TYPE vbeln_vf,
           zuonr TYPE ordnr_v,
           dueyr TYPE zdueyr,
         END OF lt_zfvato.
  DATA : lt_temp  LIKE lt_zfvato OCCURS 0 WITH HEADER LINE.

  IF gt_record[] IS NOT INITIAL.
    SELECT vkorg vkbur vatno vbeln zuonr dueyr
      FROM zfvato
      INTO TABLE lt_zfvato
      FOR ALL ENTRIES IN gt_record
      WHERE vkorg	= gt_record-vkorg
        AND vkbur	= gt_record-vkbur
        AND vbeln	= gt_record-vbeln
        AND zuonr	= gt_record-zuonr
        AND dueyr	= gt_record-dueyr.
  ENDIF.

  IF gt_temp[] IS NOT INITIAL.
    SELECT vkorg vkbur vatno vbeln zuonr dueyr
      FROM zfvato
      INTO TABLE lt_temp
      FOR ALL ENTRIES IN gt_temp
      WHERE vkorg	= gt_temp-vkorg
        AND vkbur	= gt_temp-vkbur
        AND vbeln	= gt_temp-vbeln
        AND zuonr	= gt_temp-zuonr
        AND dueyr	= gt_temp-dueyr.
  ENDIF.

  SORT gt_record BY vkorg vkbur vbeln zuonr dueyr.
  SORT lt_zfvato BY vkorg vkbur vbeln zuonr dueyr.
  SORT lt_temp BY vkorg vkbur vbeln zuonr dueyr.

  LOOP AT gt_record.
    READ TABLE lt_zfvato WITH KEY vkorg	= gt_record-vkorg
                                  vkbur	= gt_record-vkbur
                                  vbeln	= gt_record-vbeln
                                  zuonr	= gt_record-zuonr
                                  dueyr	= gt_record-dueyr
                         BINARY SEARCH.
    IF sy-subrc = 0.
      gt_record-icon  = icon_led_green.
    ELSE.
      SHIFT gt_record-vbeln LEFT DELETING LEADING '0'.
      READ TABLE lt_temp WITH KEY vkorg	= gt_record-vkorg
                                    vkbur	= gt_record-vkbur
                                    vbeln	= gt_record-vbeln
                                    zuonr	= gt_record-zuonr
                                    dueyr	= gt_record-dueyr
                           BINARY SEARCH.
      IF sy-subrc = 0.
        gt_record-icon  = icon_led_green.
      ELSE.
        gt_record-icon  = icon_led_red.
      ENDIF.
    ENDIF.
    MODIFY gt_record.
    CLEAR gt_record.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_DATA_UPLOAD

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_MAIN
*&---------------------------------------------------------------------*
FORM f_modify_itab_main .
  DATA: lt_main LIKE i_main OCCURS 0 WITH HEADER LINE.
  DATA: lt_zfvatdtcust TYPE TABLE OF zfvatdtcust WITH HEADER LINE.
  DATA: lt_zfcustaddr TYPE TABLE OF zfcustaddr WITH HEADER LINE.
  DATA: BEGIN OF lt_bseg OCCURS 0,
          bukrs LIKE bseg-bukrs,
          belnr LIKE bseg-belnr,
          gjahr LIKE bseg-gjahr,
          buzei LIKE bseg-buzei,
          bschl LIKE bseg-bschl,
          zfbdt LIKE bseg-zfbdt,
          zterm LIKE bseg-zterm,
        END OF lt_bseg.

  DATA: BEGIN OF lt_kna1 OCCURS 0,
          kunnr      LIKE kna1-kunnr,
          adrnr      LIKE kna1-adrnr,
          stceg      LIKE kna1-stceg,
          name_co    LIKE adrc-name_co,
          str_suppl1 LIKE adrc-str_suppl1,
          str_suppl2 LIKE adrc-str_suppl2,
          str_suppl3 LIKE adrc-str_suppl3,
          location   LIKE adrc-location,
        END OF lt_kna1.

  SELECT * INTO TABLE lt_zfvatdtcust
    FROM zfvatdtcust WHERE vkorg = p_vkorg.

  SELECT * INTO TABLE lt_zfcustaddr
    FROM zfcustaddr WHERE vkorg = p_vkorg.

  IF lt_zfcustaddr[] IS NOT INITIAL.
    SELECT kunnr adrnr stceg name_co str_suppl1 str_suppl2 str_suppl3
      location
      INTO CORRESPONDING FIELDS OF TABLE lt_kna1
      FROM kna1 AS a JOIN adrc AS b ON b~addrnumber = a~adrnr
      FOR ALL ENTRIES IN lt_zfcustaddr
      WHERE kunnr = lt_zfcustaddr-kunag.
  ENDIF.

  IF i_main[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr buzei bschl zfbdt zterm
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg
      FROM bseg FOR ALL ENTRIES IN i_main
      WHERE bukrs = i_main-vkorg
        AND belnr = i_main-vbeln
        AND gjahr = i_main-erdat(4)
        AND bschl = '01'.

    LOOP AT i_main ASSIGNING <fs_main>.
      CLEAR: lt_zfvatdtcust,lt_zfcustaddr,lt_bseg,lt_kna1.
      READ TABLE lt_bseg WITH KEY bukrs = <fs_main>-vkorg
                                  belnr = <fs_main>-vbeln
                                  gjahr = <fs_main>-erdat(4)
                                  bschl = '01'.
      READ TABLE lt_zfvatdtcust WITH KEY vkorg = <fs_main>-vkorg
                                         kunwe = <fs_main>-kunrg.
      IF sy-subrc = 0.
        IF lt_zfvatdtcust-datab LE lt_bseg-zfbdt.
          <fs_main>-dueyr = lt_bseg-zfbdt(4).
          <fs_main>-dudat = lt_bseg-zfbdt.
        ENDIF.
      ENDIF.

      READ TABLE lt_zfcustaddr WITH KEY vkorg = <fs_main>-vkorg
                                        kunwe = <fs_main>-kunrg.
      IF sy-subrc = 0.
        READ TABLE lt_kna1 WITH KEY kunnr = lt_zfcustaddr-kunag.
        IF lt_zfcustaddr-datab LE lt_bseg-zfbdt AND
           lt_zfcustaddr-datbi GE lt_bseg-zfbdt.
          <fs_main>-name_co    = lt_kna1-name_co.
          <fs_main>-str_suppl1 = lt_kna1-str_suppl1.
          <fs_main>-str_suppl2 = lt_kna1-str_suppl2.
          <fs_main>-stras      = lt_kna1-str_suppl3.
          <fs_main>-stceg      = lt_kna1-stceg.
          <fs_main>-location   = lt_kna1-location.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_ITAB_MAIN

*&---------------------------------------------------------------------*
*&      Form  F_BILLING_TYPE
*&---------------------------------------------------------------------*
FORM f_billing_type USING fu_fkart.
  DATA : lr_fkart   LIKE LINE OF gr_fkart.

  lr_fkart-low    = fu_fkart.
  lr_fkart-sign   = 'E'.
  lr_fkart-option = 'EQ'.
  APPEND lr_fkart TO gr_fkart.
  CLEAR lr_fkart.
ENDFORM.                    " F_BILLING_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_GET_VBRP
*&---------------------------------------------------------------------*
FORM f_get_vbrp .
  DATA : lr_vkbur TYPE RANGE OF vkbur,
         ls_vkbur LIKE LINE OF lr_vkbur.

  ls_vkbur-low    = 'T2*'.
  ls_vkbur-sign   = 'I'.
  ls_vkbur-option = 'CP'.
  APPEND ls_vkbur TO lr_vkbur.
  CLEAR ls_vkbur.

  IF p_bahan IS INITIAL.
    SELECT *
      FROM vbrp
      INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
      FOR ALL ENTRIES IN i_sap
      WHERE vbeln = i_sap-vbeln
        AND vkbur IN lr_vkbur
        AND ktgrm IN ('07','08').
  ELSE.
    SELECT *
     FROM vbrp
     INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
     FOR ALL ENTRIES IN i_sap
     WHERE vbeln = i_sap-vbeln
       AND vkbur IN lr_vkbur
       AND ktgrm NE '08'.
  ENDIF.
ENDFORM.                    " F_GET_VBRP

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_budat fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_budat
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC
