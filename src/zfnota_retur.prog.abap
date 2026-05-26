*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK935904     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zfnota_retur NO STANDARD PAGE HEADING
                    LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.

*------------------standard common includes---ends---------------------*

*------------------common TOP includes for the program----------------*
INCLUDE zfnota_returtop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS:
  pa_vkorg LIKE vbrk-vkorg OBLIGATORY DEFAULT '8020' MODIF ID vko,
  pa_vkbur LIKE vbrp-vkbur MODIF ID vk1,
  pa_kunnr LIKE knvv-kunnr MODIF ID ku1.
SELECT-OPTIONS:
  so_vkbur FOR vbrp-vkbur MODIF ID vk2,
  so_kunnr FOR vbrk-kunrg MODIF ID ku2,
  so_nonr  FOR zfppnnrh-nonr MODIF ID non,
  so_nrdt  FOR zfppnnrh-nrdt MODIF ID ndt,
  so_vbeln FOR vbrk-vbeln MODIF ID vbe,
  so_fkdat FOR vbrk-fkdat MODIF ID fkd.
SELECT-OPTIONS:
  so_mona1 FOR bsid-monat MODIF ID mo2,
  so_gjah1 FOR bsid-gjahr MODIF ID gj2.
SELECTION-SCREEN BEGIN OF BLOCK data3 WITH FRAME TITLE TEXT-040.
PARAMETERS:
  pa_monat LIKE bsid-monat MODIF ID mon,
  pa_gjahr LIKE bsid-gjahr MODIF ID gjh,
  pa_vrsio LIKE zfppnnrh-vrsio MODIF ID vrs.
SELECT-OPTIONS:
  so_vrsio FOR zfppnnrh-vrsio MODIF ID vr1 NO INTERVALS,
  so_monat FOR bsid-monat MODIF ID mo1 NO INTERVALS NO-EXTENSION,
  so_gjahr FOR bsid-gjahr MODIF ID gj1 NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK data3.
PARAMETERS:
  filename LIKE rlgrap-filename MODIF ID fln.
SELECTION-SCREEN SKIP 1.
*PARAMETERS: p_nmpem1(20) MODIF ID npe,
*            p_japem1(20) MODIF ID jpe.
PARAMETERS:
  p_dest1 LIKE tsp03l-lname MODIF ID des.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio11 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-101 FOR FIELD radio11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio14 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-104 FOR FIELD radio14.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio12 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-102 FOR FIELD radio12.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio15 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-012 FOR FIELD radio15.
SELECTION-SCREEN POSITION 40.
PARAMETERS: pa_down AS CHECKBOX MODIF ID pdw USER-COMMAND chk.
SELECTION-SCREEN : COMMENT 43(35) TEXT-013 FOR FIELD pa_down.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-006 FOR FIELD radio4.
SELECTION-SCREEN POSITION 40.
SELECTION-SCREEN : COMMENT 41(22) TEXT-009.
PARAMETERS:
  pa_vari LIKE disvariant-variant MODIF ID var.
SELECTION-SCREEN END OF LINE.
PARAMETERS: radio10 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-007 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) TEXT-010 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
PARAMETERS: radio7 RADIOBUTTON GROUP grp1.
PARAMETERS: radio8 RADIOBUTTON GROUP grp1.
PARAMETERS: radio9 RADIOBUTTON GROUP grp1.
PARAMETERS: radio13 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data1.

* SCREEN 500
SELECTION-SCREEN BEGIN OF SCREEN 500 AS WINDOW TITLE TEXT-020.
SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME.
SELECTION-SCREEN BEGIN OF BLOCK data4 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: kunnr(10) MODIF ID kun.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: name(100) MODIF ID nam.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: name_co1(100) MODIF ID nco.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: street LIKE adrc-str_suppl1 MODIF ID str.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: city(100) MODIF ID cit.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data4.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(16) TEXT-021.
SELECTION-SCREEN POSITION 19.
PARAMETERS: nonr LIKE zfppnnrh-nonr OBLIGATORY MODIF ID nnr.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) TEXT-022.
SELECTION-SCREEN POSITION 19.
PARAMETERS: nrdt LIKE zfppnnrh-nrdt OBLIGATORY MODIF ID nrd.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-035.
SELECTION-SCREEN POSITION 19.
PARAMETERS: ttlnr LIKE zfppnnrh-ttlnr OBLIGATORY MODIF ID tot.
SELECTION-SCREEN POSITION 50.
PARAMETERS: rvat1 RADIOBUTTON GROUP grp2 MODIF ID vat USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 52(20) TEXT-041 FOR FIELD rvat1 MODIF ID vat.
PARAMETERS: vatno LIKE zfvato-vatpr AS LISTBOX VISIBLE LENGTH 20 MODIF ID va1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-024.
SELECTION-SCREEN POSITION 19.
PARAMETERS: dppnr LIKE zfppnnrh-dppnr OBLIGATORY MODIF ID tot.
SELECTION-SCREEN POSITION 50.
PARAMETERS: rvat2 RADIOBUTTON GROUP grp2 MODIF ID vat.
SELECTION-SCREEN COMMENT 52(20) TEXT-042 FOR FIELD rvat2 MODIF ID vat.
PARAMETERS: vatnotxt LIKE zfvato-vatpr MODIF ID va2 OBLIGATORY.
PARAMETERS: vatdate  LIKE zfppnnrh-vatdt1 OBLIGATORY MODIF ID va2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-023.
SELECTION-SCREEN POSITION 19.
PARAMETERS: ppnnr LIKE zfppnnrh-ppnnr OBLIGATORY MODIF ID tot.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_city LIKE zfppnnrh-city OBLIGATORY MODIF ID pre.
PARAMETERS: p_nmpem LIKE zfppnnrh-nmpem OBLIGATORY MODIF ID pre,
            p_japem LIKE zfppnnrh-japem OBLIGATORY MODIF ID pre.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_dest LIKE tsp03l-lname MODIF ID pre.
SELECTION-SCREEN END OF BLOCK data2.
SELECTION-SCREEN END OF SCREEN 500.

SELECTION-SCREEN BEGIN OF SCREEN 502 AS WINDOW TITLE TEXT-502.
SELECTION-SCREEN BEGIN OF BLOCK data5 WITH FRAME.
PARAMETERS: pa_fakt1 LIKE tline-tdline MODIF ID fk1,
            pa_fakt2 LIKE tline-tdline MODIF ID fk2,
            pa_fakt3 LIKE tline-tdline MODIF ID fk3,
            pa_fakt4 LIKE tline-tdline MODIF ID fk4.
SELECTION-SCREEN END OF BLOCK data5.
SELECTION-SCREEN END OF SCREEN 502.

INCLUDE zabp_smartform.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA: ld_date      TYPE sy-datum,
        ld_date1     TYPE sy-datum,
        ld_vrsio     LIKE zfppnnrh-vrsio,
        ld_vrsio1(3) TYPE n.

  SELECT SINGLE usergroup INTO va_usrgrp
    FROM usgrp_user
    WHERE bname EQ sy-uname AND
          usergroup EQ 'FINHO'.

  SELECT SINGLE a~spld b~lname
    FROM usr01 AS a JOIN tsp03l AS b ON a~spld EQ b~padest
    INTO (va_spld, p_dest)
    WHERE a~bname EQ sy-uname.

  p_dest1 = p_dest.

  ld_date  = sy-datum.
  ld_date1 = '20070101'.
  DO 3 TIMES.
    CONCATENATE ld_date(6) '01' INTO ld_date.
    ld_date = ld_date - 1.
  ENDDO.

  IF ld_date LT ld_date1.
    ld_date = ld_date1.
  ENDIF.
  CONCATENATE ld_date(6) '01' INTO ld_date.
  so_fkdat-low  = ld_date.
  so_fkdat-high = sy-datum.
  APPEND so_fkdat.

  SELECT *
    FROM zfnrclose
    INTO CORRESPONDING FIELDS OF TABLE t_close.

  SELECT MAX( vrsio ) INTO ld_vrsio
    FROM zfppnnrh.
  IF ld_vrsio IS INITIAL.
    pa_vrsio = '001'.
  ELSE.
    ld_vrsio1 = ld_vrsio.
    ADD 1 TO ld_vrsio1.
    pa_vrsio = ld_vrsio1.
  ENDIF.

  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_vkorg  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.

  IF sy-subrc EQ 0.
    pa_vkbur  = lv_parva.
  ENDIF.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR filename.
  PERFORM f_filename_f4 CHANGING filename.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_f4_for_variant_alv USING pa_vari
                               CHANGING d_alv_desc.

AT SELECTION-SCREEN ON pa_vkbur.
  IF NOT pa_vkbur IS INITIAL.
    AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
      ID 'VKBUR' FIELD pa_vkbur
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE e000(zab) WITH
      'You have no authorization for Sales Office' pa_vkbur.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON filename.
  IF NOT pa_vkbur IS INITIAL.
    SELECT SINGLE brcode live mixlive
      FROM znrmap
      INTO (va_brcode, va_live, va_mixlive)
      WHERE vkorg EQ pa_vkorg AND
            vkbur EQ pa_vkbur.

    CONCATENATE 'NR' va_brcode 'H' pa_monat
    INTO va_perio.
    CONCATENATE '*NR' va_brcode 'H' pa_monat '*.txt'
    INTO va_name.
  ENDIF.

  IF radio3 EQ 'X'.
    IF NOT filename IS INITIAL.
      IF filename NP va_name.
        MESSAGE e000(zab) WITH 'Filename salah'.
      ENDIF.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  IF radio2 EQ 'X'.
    IF pa_vrsio IS INITIAL AND va_usrgrp IS NOT INITIAL.
      MESSAGE 'Version must entries' TYPE 'E'.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.
  PERFORM f_modify_screen_500.
  PERFORM f_modify_screen_502.
  PERFORM f_vatno_listbox.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  DATA: ld_mess(50) VALUE 'Make an entry in all required fields'.

  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN 'RAD'.
      PERFORM f_validate_screen_1000_rad.
    WHEN space.
      PERFORM f_validate_screen_1000.
    WHEN 'CRET'.
      PERFORM f_validate_screen_500.
      IF va_valcust EQ 0.

        PERFORM f_isi_table.

        IF NOT t_zfppnnrh[] IS INITIAL.
          va_commit = 0.
          PERFORM f_commit_work ON COMMIT.
        ENDIF.

        IF sy-subrc EQ 0.
          IF va_error EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
          CASE 'X'.
            WHEN radio1.
              PERFORM f_table_unlocking.
              IF va_error EQ 0.
                MESSAGE s000(zab)
                WITH 'Records was CREATED successfully'.
              ELSE.
                MESSAGE e000(zab) WITH 'Customer tidak ada N.P.W.P'.
              ENDIF.
              LEAVE TO SCREEN 0.
          ENDCASE.
        ELSE.
          MESSAGE e000(zab) WITH 'Processing error'.
        ENDIF.
      ELSE.
* Check print preview
        PERFORM f_validate_screen_500.

        IF p_dest IS INITIAL.
          LOOP AT SCREEN.
            IF screen-group1 EQ 'PRE'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH ld_mess.
        ELSE.
*          IF t_out6[] IS NOT INITIAL.
          PERFORM f_view_detail.
          va_preview = 1.
          PERFORM f_alv TABLES t_out6.
          LEAVE TO SCREEN 0.
*          ELSE.
*            va_legacy = 1.
*            PERFORM f_isi_table.
*
*            IF NOT t_zfppnnrh[] IS INITIAL.
*              va_commit = 0.
*              PERFORM f_commit_work ON COMMIT.
*            ENDIF.
*
*            IF sy-subrc EQ 0.
*              IF va_error EQ 0.
*                COMMIT WORK AND WAIT.
*              ELSE.
*                ROLLBACK WORK.
*              ENDIF.
*              CASE 'X'.
*                WHEN radio1.
*                  PERFORM f_table_unlocking.
*                  IF va_error EQ 0.
*                    MESSAGE s000(zab)
*                    WITH 'Records was CREATED successfully'.
*                  ELSE.
*                    MESSAGE e000(zab) WITH 'Customer tidak ada N.P.W.P'.
*                  ENDIF.
*                  LEAVE TO SCREEN 0.
*              ENDCASE.
*            ELSE.
*              MESSAGE e000(zab) WITH 'Processing error'.
*            ENDIF.
*        ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

  PERFORM f_validate_screen_500.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  DATA: BEGIN OF lt_zfnrrange OCCURS 0.
          INCLUDE STRUCTURE zfnrrange.
        DATA: END OF lt_zfnrrange.

  IF pa_vkorg EQ '8020'.
    gv_gsber  = '0200'.
    gv_brcod  = 'C'.
  ELSEIF pa_vkorg EQ '8070'.
    gv_gsber  = pa_vkbur.
    gv_brcod  = 'S'.
  ENDIF.

  IF va_error IS INITIAL.
    CASE 'X'.
      WHEN radio15.
        IF pa_down IS NOT INITIAL.
          PERFORM f_get_data_download.
        ELSE.
          PERFORM f_check_extension USING filename
                                    CHANGING gv_extension.
          CASE gv_extension.
            WHEN 'TXT' OR 'txt'.
              PERFORM f_get_data_upload_txt USING filename.
            WHEN OTHERS.
              PERFORM f_get_data_upload.
          ENDCASE.
          PERFORM f_upldt_validate.
          PERFORM f_print_data.
        ENDIF.
      WHEN radio14.
        IF va_usrgrp IS INITIAL.
          MESSAGE 'Anda tidak mempunyai autorisasi untuk menjalankan fungsi ini' TYPE 'I'.
        ELSE.
          PERFORM f_upload_excel TABLES t_zfstppnnr
                                 USING filename.
          PERFORM f_init_data.
          PERFORM f_get_data.
          PERFORM f_process_data.
          PERFORM f_print_data.
        ENDIF.

      WHEN radio3.
        PERFORM f_gui_upload_file TABLES t_record
                                  USING filename.
        PERFORM f_validate_data.
        PERFORM f_process_data.
        PERFORM f_print_data.

      WHEN radio6.
        PERFORM f_dynpro USING:
           'X'  'SAPMSVMA'                '0100',
           ' '  'BDC_OKCODE'              '=UPD',
           ' '  'VIEWNAME'                'ZFNRCLOSE',
           ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
           ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

           'X'  'SAPLSVIX'                '0210',
           ' '  'MARK_CHECKBOX(01)'       'X',

           'X'  'SAPLSVIX'                '0100',
           ' '  'BDC_OKCODE'              '=OKAY',
           ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_vkorg.

        CALL TRANSACTION 'YF01' USING i_bdc
                                MODE 'E'
                                UPDATE 'S'
                                MESSAGES INTO i_messtab.

        PERFORM f_validate_radio6.

      WHEN radio8.
        IF va_usrgrp IS INITIAL.
          MESSAGE 'Anda tidak mempunyai autorisasi untuk menjalankan fungsi ini' TYPE 'I'.
        ELSE.
          CLEAR i_bdc.
          PERFORM f_dynpro USING:
             'X'  'SAPMSVMA'                '0100',
             ' '  'BDC_OKCODE'              '=UPD',
             ' '  'VIEWNAME'                'ZFNRCUSTM',
             ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
             ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

             'X'  'SAPLSVIX'                '0210',
             ' '  'MARK_CHECKBOX(01)'       'X',
             ' '  'MARK_CHECKBOX(02)'       'X',

             'X'  'SAPLSVIX'                '0100',
             ' '  'BDC_OKCODE'              '=OKAY',
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_vkorg,
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' pa_vkbur.

          CALL TRANSACTION 'YF01' USING i_bdc
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO i_messtab.
        ENDIF.

      WHEN radio9.
        IF va_usrgrp IS INITIAL.
          MESSAGE 'Anda tidak mempunyai autorisasi untuk menjalankan fungsi ini' TYPE 'I'.
        ELSE.
          CLEAR i_bdc.
          PERFORM f_dynpro USING:
             'X'  'SAPMSVMA'                '0100',
             ' '  'BDC_OKCODE'              '=UPD',
             ' '  'VIEWNAME'                'ZFNRRANGE',
             ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
             ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

             'X'  'SAPLSVIX'                '0210',
             ' '  'MARK_CHECKBOX(01)'       'X',
             ' '  'MARK_CHECKBOX(02)'       'X',
             ' '  'MARK_CHECKBOX(04)'       'X',

             'X'  'SAPLSVIX'                '0100',
             ' '  'BDC_OKCODE'              '=OKAY',
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_vkorg,
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' pa_vkbur,
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(03)' 'IDR'.

          CALL TRANSACTION 'YF01' USING i_bdc
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO i_messtab.
          IF sy-subrc EQ 0.
            SELECT SINGLE *
              FROM zfnrrange
              INTO lt_zfnrrange
              WHERE vkorg EQ pa_vkorg AND
                    vkbur EQ pa_vkbur AND
                    kunnr EQ pa_kunnr.
            IF sy-subrc EQ 0.
              lt_zfnrrange-usna1 = sy-uname.
              lt_zfnrrange-erdt1 = sy-datum.
              lt_zfnrrange-erzet = sy-uzeit.
              MODIFY zfnrrange FROM lt_zfnrrange.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN radio12.
        SELECT *
          FROM zfnrstatus
          INTO CORRESPONDING FIELDS OF TABLE t_zfnrstatus.
        PERFORM f_gui_upload_excel USING filename.
        PERFORM f_process_nr.
        PERFORM f_print_data.

      WHEN radio13.
        IF va_usrgrp IS INITIAL.
          MESSAGE 'Anda tidak mempunyai autorisasi untuk menjalankan fungsi ini' TYPE 'I'.
        ELSE.
          CLEAR i_bdc.
          PERFORM f_dynpro USING:
             'X'  'SAPMSVMA'                '0100',
             ' '  'BDC_OKCODE'              '=UPD',
             ' '  'VIEWNAME'                'ZFNRCNCUST',
             ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
             ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

             'X'  'SAPLSVIX'                '0210',
             ' '  'MARK_CHECKBOX(01)'       'X',
             ' '  'MARK_CHECKBOX(02)'       'X',

             'X'  'SAPLSVIX'                '0100',
             ' '  'BDC_OKCODE'              '=OKAY',
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_vkorg,
             ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' pa_vkbur.

          CALL TRANSACTION 'YF01' USING i_bdc
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO i_messtab.
        ENDIF.

      WHEN OTHERS.
        IF radio11 = 'X' AND va_usrgrp IS INITIAL.
          MESSAGE 'Anda tidak mempunyai autorisasi untuk menjalankan fungsi ini' TYPE 'I'.
        ELSE.
          PERFORM f_init_data.
          PERFORM f_get_data.
          PERFORM f_table_locking.
          PERFORM f_process_data.
          PERFORM f_print_data.
        ENDIF.
    ENDCASE.

    PERFORM f_free_memory.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zfnota_returf01.

*------------------common includes for the program---------------------*
