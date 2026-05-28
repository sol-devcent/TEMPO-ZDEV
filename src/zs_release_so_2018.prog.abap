REPORT zs_release_so MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 63(3)
                                  LINE-SIZE  150.


************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  :                                                        *
* Created on  :                                                        *
* Version     : 0.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*
****************************************************
*        Tables                                    *
****************************************************
TABLES: tvko,
        tvkov,
        tvkbz,
        tvbvk,
        kna1,
        zscl_class,
        zsauth, zscl_trading,
        zsrange_so, vbuk,
        vbak.


************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_key,
          vbeln LIKE vbuk-vbeln,
        END OF t_key.


TYPES : BEGIN OF t_itab1,
          vkbur    LIKE vbak-vkbur,
          vbeln    LIKE vbak-vbeln,
          kunnr    LIKE vbak-kunnr,
          netwr    LIKE vbak-netwr,
          audat    LIKE vbak-audat,
          lifsk    LIKE vbak-lifsk,
          name1    LIKE kna1-name1,
          auth(1),
          usrgroup LIKE zsauth-usrgroup,
          auart    LIKE vbak-auart,
          mini(1),
          bnddt    LIKE vbak-bnddt,
          kvgr3    LIKE vbak-kvgr3,
        END OF t_itab1.


TYPES:   BEGIN OF t_bdc.
           INCLUDE STRUCTURE bdcdata.
         TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
           INCLUDE STRUCTURE bdcmsgcoll.
         TYPES:   END OF t_messtab.




************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************


DATA: gt_zscl_trading TYPE zscl_trading OCCURS 0,
      gs_zscl_trading TYPE zscl_trading.

DATA:
  v_line_size     TYPE i,
  v_line_size_sum TYPE i,
  va_mark(1),
  c1              TYPE i,
  c2              TYPE i,
  c3              TYPE i,
  c4              TYPE i,
  w1              TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
  w5              TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
  w9              TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
  w13             TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
  w17             TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
  w20             TYPE i,  w17a  TYPE i,
  w21             TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
  w25             TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
  w29             TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
  w33             TYPE i,  w34   TYPE i,  w35   TYPE i.

DATA: i_bdc           TYPE t_bdc OCCURS 0,
      wa_bdc          TYPE t_bdc,
      i_messtab       TYPE t_messtab OCCURS 0,
      wa_messtab      TYPE t_messtab,
      i_itab1         TYPE t_itab1 OCCURS 0,
      i_itab3         TYPE t_itab1 OCCURS 0,
      i_itab2         TYPE t_itab1 OCCURS 0,
      wa_itab1        TYPE t_itab1,
      msg(80),
      i_key           TYPE t_key OCCURS 0,
      wa_key          TYPE t_key,

      va_zclass       LIKE zscl_class-zclass,
      va_zcode        LIKE zsauth-zcode,
      va_zvalue_high  LIKE zsrange_so-zvalue_high,
      va_usrgroup     LIKE zscl_user-usrgroup,
      va_usrgroup1    LIKE zscl_user-usrgroup,
      va_netwr        LIKE zsmov-netwr,
      va_vbeln        LIKE vbak-vbeln,
      wa_zghsd_doc_so LIKE zghsd_doc_so,
      va_remark(25).

DATA: va_value         LIKE vbak-vbeln,
      va_fieldname(30).
DATA  panjang TYPE i..

DATA : gt_usrgrp   TYPE STANDARD TABLE OF usgrp_user.

************************************************************************
* INCLUDES                                                             *
************************************************************************
INCLUDE <%_list>.

DATA: va_line(1024),
      va_linectr    TYPE i,
      va_mode(1),
      va_list       TYPE slist_listline.

RANGES: ra_kkber FOR knvv-kkber.
DATA: gt_zsmapping_soff TYPE zsmapping_soff OCCURS 0,
      gs_zsmapping_soff TYPE zsmapping_soff.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS pa_vkorg LIKE tvko-vkorg  OBLIGATORY DEFAULT '8020'.
PARAMETERS pa_vkbur LIKE tvkbz-vkbur OBLIGATORY.
SELECT-OPTIONS: so_vtweg FOR  tvkov-vtweg,
                so_vkgrp FOR  tvbvk-vkgrp,
                so_kunnr FOR  kna1-kunnr,
                so_vbeln FOR  vbak-vbeln,
                so_audat FOR  vbak-audat,
                so_erdat FOR  vbak-erdat.
*      Parameters pa_USeR(3) default 'SPV'.
SELECTION-SCREEN SKIP 1.
PARAMETERS: pa_test DEFAULT 'X' AS CHECKBOX  MODIF ID rea.
PARAMETERS: pa_mini DEFAULT ' ' AS CHECKBOX .

SELECTION-SCREEN END OF BLOCK block1.
************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON pa_vkbur.
  AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
      ID 'VKBUR' FIELD pa_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
             pa_vkbur.
  ENDIF.

AT SELECTION-SCREEN ON pa_mini.
  IF pa_mini = 'X'.
    CLEAR va_usrgroup.
    SELECT SINGLE usergroup INTO  va_usrgroup
            FROM usgrp_user
            WHERE bname  = sy-uname.
    IF sy-subrc EQ 0.
      IF va_usrgroup = 'BM' OR va_usrgroup = 'BSM' OR
        va_usrgroup = 'MD' OR va_usrgroup = 'VIP' OR
        va_usrgroup = 'MDDD' OR va_usrgroup = 'SFD' OR
        va_usrgroup = 'FD' OR va_usrgroup = 'DSOD' OR
        va_usrgroup = 'SOD' OR va_usrgroup = 'SD'  OR
       va_usrgroup EQ 'CFO'.
      ELSE.
*        MESSAGE e002(zz) WITH 'Khusus User Group BM atau BSM'.
*        MESSAGE e002(zz) WITH 'Release khusus User Group DSOD'.
        MESSAGE e002(zz) WITH 'User Group' va_usrgroup
                              'Not Authorized to Release'.
      ENDIF.
    ENDIF.

***    PERFORM f_validasi_user_group.
  ENDIF.
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  LOOP AT SCREEN.
    IF screen-group1 = 'REA'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF pa_mini = 'X'.
    NEW-PAGE LINE-SIZE 122.
    panjang = 122.
  ELSE.
    NEW-PAGE LINE-SIZE 94.
    panjang = 94.
  ENDIF.


  PERFORM f_init_column.
************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  IF pa_mini = 'X'.
    NEW-PAGE LINE-SIZE 135.
    panjang = 135.
  ELSE.
    NEW-PAGE LINE-SIZE 107.
    panjang = 107.
  ENDIF.

  ra_kkber-low    = '8000'.
  ra_kkber-sign   = 'I'.
  ra_kkber-option = 'EQ'.
  APPEND ra_kkber.
*ra_kkber-low    = '8020'.
  ra_kkber-low    = pa_vkorg.
  ra_kkber-sign   = 'I'.
  ra_kkber-option = 'EQ'.
  APPEND ra_kkber.

  SET PF-STATUS '100'.
  IF pa_test = 'X'.
    va_mode = 'N'.
  ELSE.
    va_mode = 'A'.
  ENDIF.
* MODE       = 'N'.    "Running BackGroud
* MODE       = 'A'.    "Running Fore Groud

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zsmapping_soff FROM zsmapping_soff
     WHERE vkbur1 = pa_vkbur AND
           datab <= sy-datum AND
           datbi >= sy-datum.

  SELECT * INTO TABLE gt_zscl_trading  FROM zscl_trading.


  PERFORM f_get_data.

  SELECT SINGLE zclass INTO va_zclass
         FROM zscl_class
         WHERE vkbur EQ pa_vkbur.
  IF sy-subrc <> 0.
    va_zclass = 'A'.
  ENDIF.

  CLEAR va_usrgroup.
  SELECT SINGLE usergroup INTO  va_usrgroup
          FROM usgrp_user
          WHERE bname  = sy-uname.
  IF sy-subrc EQ 0.
    IF va_usrgroup = space.
      va_usrgroup  = '*'.
    ENDIF.
  ELSE.
    va_usrgroup = '*'.
  ENDIF.

********************************************************
*va_USRGROUP  = pa_user.
********************************************************

  CLEAR wa_itab1.
  LOOP AT i_itab1 INTO wa_itab1.
    wa_itab1-netwr = wa_itab1-netwr * 110 / 100.
    IF va_usrgroup EQ 'BM' OR va_usrgroup EQ 'BSM' OR
       va_usrgroup EQ 'MD' OR va_usrgroup EQ 'VIP' OR
       va_usrgroup EQ 'MDDD' OR va_usrgroup EQ 'SFD' OR
       va_usrgroup EQ 'FD' OR va_usrgroup EQ 'DSOD' OR
       va_usrgroup EQ 'SOD' OR va_usrgroup EQ 'SD'  OR
       va_usrgroup EQ 'CFO'.
    ELSE.
**      AUTHORITY-CHECK OBJECT 'ZSKVGR3'
**          ID 'KVGR3' FIELD wa_itab1-kvgr3.
**      IF sy-subrc NE 0.
**        CONTINUE.
**      ENDIF.
      IF va_usrgroup = 'TTSH'.
        IF wa_itab1-kvgr3 NE '05T'.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    MOVE va_usrgroup TO wa_itab1-usrgroup.
    SELECT SINGLE zcode INTO va_zcode
           FROM zsauth
           WHERE usrgroup EQ wa_itab1-usrgroup AND
                 zclass   EQ va_zclass.
    IF sy-subrc EQ 0.
      SELECT SINGLE zvalue_high INTO va_zvalue_high
             FROM zsrange_so
             WHERE zclass EQ va_zclass AND
                   zcode  EQ va_zcode  AND
                   zvalue_high >= wa_itab1-netwr.
      IF sy-subrc EQ 0.
        wa_itab1-auth = 'X'.
        SELECT SINGLE netwr INTO va_netwr
          FROM zsmov2 WHERE auart = wa_itab1-auart
                        AND kvgr3 = wa_itab1-kvgr3.
        IF sy-subrc NE 0.
          SELECT SINGLE netwr bname INTO (va_netwr , va_usrgroup1)
                  FROM zsmov
                   WHERE auart = wa_itab1-auart.
        ENDIF.
*               va_netwr = va_netwr * 100.
        IF  wa_itab1-netwr <= va_netwr  .
          wa_itab1-auth = ' '.
          wa_itab1-mini = 'X'.
          IF pa_mini = 'X'.
*            IF va_usrgroup = 'BM' OR va_usrgroup = 'BSM'.
            IF va_usrgroup = 'MD' OR va_usrgroup = 'VIP' OR
               va_usrgroup = 'MDDD' OR va_usrgroup = 'SFD' OR
               va_usrgroup = 'FD' OR va_usrgroup = 'DSOD' OR
               va_usrgroup = 'SOD' OR va_usrgroup = 'SD' OR
               va_usrgroup = 'CFO'.
              wa_itab1-auth = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        wa_itab1-auth = ' '.
      ENDIF.
    ELSE.
      wa_itab1-auth = ' '.
    ENDIF.

    IF va_usrgroup EQ 'BM' OR va_usrgroup EQ 'BSM' OR
       va_usrgroup EQ 'MD' OR va_usrgroup EQ 'VIP' OR
       va_usrgroup EQ 'MDDD' OR va_usrgroup EQ 'SFD' OR
       va_usrgroup EQ 'FD' OR va_usrgroup EQ 'DSOD' OR
       va_usrgroup EQ 'SOD' OR va_usrgroup = 'SD' OR
       va_usrgroup EQ 'CFO'.
    ELSE.
      IF wa_itab1-auth EQ 'X' AND wa_itab1-kvgr3 = '05T'.
        SORT gt_zscl_trading BY kvgr3 usrgroup.
        READ TABLE gt_zscl_trading INTO gs_zscl_trading WITH KEY
        kvgr3 = wa_itab1-kvgr3
        usrgroup = va_usrgroup
        BINARY SEARCH.
        IF sy-subrc EQ 0.
        ELSE.
          CLEAR: wa_itab1-auth.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY i_itab1 FROM wa_itab1.
    IF pa_mini = 'X'.
      IF  wa_itab1-netwr <= va_netwr.

      ELSE.
        CONTINUE.
      ENDIF.
    ELSE.
      IF  wa_itab1-netwr <= va_netwr.
        CONTINUE.
      ELSE.
      ENDIF.

    ENDIF.
    wa_itab1-netwr = wa_itab1-netwr * 100.
    PERFORM f_write_detail.
    HIDE: wa_itab1-vbeln.
    CLEAR wa_itab1.
*
  ENDLOOP.


  WRITE: / sy-uline(panjang).

END-OF-SELECTION.


TOP-OF-PAGE.
  IF pa_mini = 'X'.
    NEW-PAGE LINE-SIZE 150.
    panjang = 150.
  ELSE.
    NEW-PAGE LINE-SIZE 107.
    panjang = 107.
  ENDIF.
  PERFORM f_write_header.
  FORMAT COLOR 4.
  PERFORM f_write_column_header.

END-OF-PAGE.


************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'EXECUTE'.
      LOOP AT %_list INTO va_list.
        CLEAR: va_vbeln, va_remark.
        IF va_list-line+3(1) = 'X'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_list-line+7(10)
            IMPORTING
              output = va_vbeln.


          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
* Rev by : SDDIK karena pada tanggal 06.10.2020 tidak bisa release ZS02 minimum order
*             input  = va_list-line+94(25)
              input  = va_list-line+107(25)
            IMPORTING
              output = va_remark.

* Rev by : SDDIK karena pada tanggal 06.10.2020 tidak bisa release ZS02 minimum order
*          IF va_list-line+120(1) = 'X'.
          IF va_list-line+133(1) = 'X'.
            IF va_remark IS INITIAL.
              MESSAGE w002(zz) WITH 'Kolom keteragan harus diisi no. surat'.
              LEAVE TO SCREEN 0.
            ENDIF.
            LOOP AT i_itab1 INTO wa_itab1 WHERE vbeln = va_vbeln.
              wa_zghsd_doc_so-vkbur = pa_vkbur.
              wa_zghsd_doc_so-auart = wa_itab1-auart.
              wa_zghsd_doc_so-vbeln = wa_itab1-vbeln.
              wa_zghsd_doc_so-name1 = va_remark.
              wa_zghsd_doc_so-bname = sy-uname.
              wa_zghsd_doc_so-utime = sy-uzeit.
              wa_zghsd_doc_so-udate = sy-datum.
              MODIFY zghsd_doc_so FROM wa_zghsd_doc_so.
            ENDLOOP.
          ENDIF.

          WRITE: / 'No. So : ', va_vbeln.

* Replace BDC to BAPI
*                 clear i_bdc.
*                 PERFORM F_DYNPRO USING:
*                    'X'  'SAPMV45A'    '0102',
*                    ' '  'BDC_CURSOR'  'VBAK-VBELN',
*                    ' '  'BDC_OKCODE'  '/00',
*                    ' '  'VBAK-VBELN'  va_VBELN,
*                    'X'  'SAPMV45A'    '4001',
**                    ' '  'BDC_OKCODE'  '=SICH',
**                    ' '  'VBAK-LIFSK'  ' '.
*                    ' '  'BDC_OKCODE'  '/00',
*                    ' '  'BDC_OKCODE'  '=KBES',
*                    ' '  'VBAK-LIFSK'  ' ',
*                    'X'  'SAPMV45A'    '4002',
*                    ' '  'BDC_OKCODE'  '=SICH',
*                    ' '  'VBAK-BNAME'  SY-UNAME.
*
*            CALL TRANSACTION 'VA02' USING i_BDC MODE va_mode UPDATE 'S'
*                      MESSAGES INTO i_MESSTAB.
*                if sy-subrc ne 0.
*                    read table i_messtab into wa_messtab index 1.
*                    CALL FUNCTION 'FORMAT_MESSAGE'
*                        EXPORTING
*                            ID       = wa_MESSTAB-MSGID
*                            LANG     = wa_MESSTAB-MSGSPRA
*                            NO       = wa_MESSTAB-MSGNR
*                            V1       = wa_MESSTAB-MSGV1
*                            V2       = wa_MESSTAB-MSGV2
*                            V3       = wa_MESSTAB-MSGV3
*                            V4       = wa_MESSTAB-MSGV4
*                       IMPORTING
*                            MSG      = MSG.
*                       write: / 'Message Error : ', msg.
*                       message e000(zs) with msg.
*                Endif.
          PERFORM f_order_change USING va_vbeln.
* End Replace BDC to BAPI

        ENDIF.
      ENDLOOP.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM 'X'.
      ENDDO.
    WHEN 'DESELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0. EXIT. ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM space.
      ENDDO.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE PROGRAM.
  ENDCASE.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CASE va_fieldname.
      WHEN 'WA_ITAB1-VBELN'.
        SET PARAMETER ID  'AUN' FIELD va_value.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.


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
*&      Form  f_init_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_column.
  w1   =   5.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  15.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =  15.      w13 = 12.      w23 = 10.      w33 = 12.
  w4   =  25.      w14 = 10.      w24 = 12.      w34 = 10.
  w5   =  15.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  12.      w16 = 12.      w26 = 10.
  w7   =  25.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  10.      w18 = 10.      w28 = 12.
  w9   =  15.      w19 = 10.      w29 = 12.
  w10  =  15.      w20 = 12.      w30 = 10.
  c1 = 0.
ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: ctr TYPE i.
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr LIKE kna1-kunnr,
        END OF lt_kunnr.
  DATA: l_numki      LIKE zsrange-numki_so,
        l_fromnumber LIKE nriv-fromnumber,
        l_nrlevel    LIKE nriv-nrlevel.

  DATA: lv_vkbur LIKE zsmapping_soff-vkbur2,
        lv_vbeln LIKE vbak-vbeln.
  RANGES: lr_auart FOR zsmapping_soff-auart, lr_vbeln FOR vbak-vbeln.

  lr_vbeln[] = so_vbeln[].
  REFRESH: lr_auart.
  LOOP AT gt_zsmapping_soff INTO gs_zsmapping_soff.
    lv_vkbur = gs_zsmapping_soff-vkbur2.
    lr_auart-sign    = 'I'.
    lr_auart-option  = 'EQ'.
    lr_auart-low     = gs_zsmapping_soff-auart.
    APPEND lr_auart.
  ENDLOOP.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  IF so_vbeln IS INITIAL.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ pa_vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE fromnumber nrlevel
             INTO (l_fromnumber, l_nrlevel) FROM nriv
             WHERE object = 'RV_BELEG' AND
                   subobject = space AND
                   nrrangenr  = l_numki.
      IF sy-subrc EQ 0.
        so_vbeln-sign = 'I'.
        so_vbeln-option = 'BT'.
        so_vbeln-low = l_fromnumber.
        so_vbeln-high = l_nrlevel+10(10).
        APPEND so_vbeln.
      ENDIF.

      IF pa_vkbur = '0201'.
        CLEAR so_vbeln[].
        so_vbeln-sign   = 'I'.
        so_vbeln-option = 'CP'.
        CONCATENATE l_fromnumber(3) '*' INTO lv_vbeln.
        so_vbeln-low    = lv_vbeln.
        so_vbeln-high   = space.
        APPEND so_vbeln.
      ENDIF.

*      IF pa_vkbur = '0252'.
*        CLEAR so_vbeln[].
*        so_vbeln-sign   = 'I'.
*        so_vbeln-option = 'CP'.
*        CONCATENATE l_fromnumber(3) '*' INTO lv_vbeln.
*        so_vbeln-low    = lv_vbeln.
*        so_vbeln-high   = space.
*        APPEND so_vbeln.
*      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.
  IF ctr <= 0.
    sy-subrc = 4.
*    MESSAGE s000(zs) WITH 'Data Not Found'.
*    LEAVE LIST-PROCESSING.
  ENDIF.

* Bila tanggal kosong, maka default data yang ditampilkan bulan ini dan
* bulan lalu
  IF so_audat IS INITIAL.
    so_audat-sign = 'I'.
    so_audat-option = 'BT'.
    so_audat-low = sy-datum.
    so_audat-low+6(2) = '01'.
    so_audat-low+4(2) = so_audat-low+4(2) - 1.
    IF so_audat-low+4(2) = 0.
      so_audat-low+4(2) = '12'.
      so_audat-low(4)   = so_audat-low(4) - 1.
    ENDIF.
    so_audat-high = sy-datum.
    APPEND so_audat.
  ENDIF.
  IF i_key[] IS NOT INITIAL.
    SELECT a~vkbur a~vbeln a~kunnr a~netwr a~audat a~lifsk b~name1 a~auart a~bnddt a~kvgr3
        INTO CORRESPONDING FIELDS OF TABLE i_itab1
        FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
                        JOIN knvv AS c  ON c~kunnr EQ a~kunnr
        FOR ALL ENTRIES IN i_key

        WHERE a~kkber IN ra_kkber AND
              a~vkorg EQ pa_vkorg AND
              a~vtweg IN so_vtweg AND
              a~vkbur EQ pa_vkbur AND
              c~vkbur EQ pa_vkbur AND
            ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
              a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
              a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
              a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
              a~vbeln EQ i_key-vbeln AND
              a~vkgrp IN so_vkgrp AND
              a~kunnr IN so_kunnr AND
              a~audat IN so_audat AND
              a~erdat IN so_erdat AND
              a~lifsk EQ 'Z1'.
  ENDIF.


*** Tambahan selection data untuk project Logika - Hu dab Sub Hu

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  IF lr_vbeln IS INITIAL.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    REFRESH: so_vbeln.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ lv_vkbur.
    IF sy-subrc = 0.
      SELECT SINGLE fromnumber nrlevel
             INTO (l_fromnumber, l_nrlevel) FROM nriv
             WHERE object = 'RV_BELEG' AND
                   subobject = space AND
                   nrrangenr  = l_numki.
      IF sy-subrc EQ 0.
        so_vbeln-sign = 'I'.
        so_vbeln-option = 'BT'.
        so_vbeln-low = l_fromnumber.
        so_vbeln-high = l_nrlevel+10(10).
        APPEND so_vbeln.
      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH: i_key.
  CLEAR: wa_key, i_key, ctr.
  SELECT vbeln
         INTO TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'C' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ ' '.

  SELECT vbeln
    APPENDING TABLE i_key FROM vbuk WHERE
              vbtyp EQ 'H' AND
              lfgsk EQ 'A' AND
              cmgst IN ('','A','C','D') AND
              bestk EQ 'C'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.

* Bila tanggal kosong, maka default data yang ditampilkan bulan ini dan
* bulan lalu
  IF so_audat IS INITIAL.
    so_audat-sign = 'I'.
    so_audat-option = 'BT'.
    so_audat-low = sy-datum.
    so_audat-low+6(2) = '01'.
    so_audat-low+4(2) = so_audat-low+4(2) - 1.
    IF so_audat-low+4(2) = 0.
      so_audat-low+4(2) = '12'.
      so_audat-low(4)   = so_audat-low(4) - 1.
    ENDIF.
    so_audat-high = sy-datum.
    APPEND so_audat.
  ENDIF.
  IF i_key[] IS NOT INITIAL AND lv_vkbur NE pa_vkbur.
    SELECT a~vkbur a~vbeln a~kunnr a~netwr a~audat a~lifsk b~name1 a~auart
        INTO CORRESPONDING FIELDS OF TABLE i_itab3
        FROM vbak AS a JOIN  kna1 AS b ON a~kunnr EQ b~kunnr
*                         JOIN knvv AS c  ON c~kunnr EQ a~kunnr
        FOR ALL ENTRIES IN i_key

        WHERE a~kkber IN ra_kkber AND
              a~vkorg EQ pa_vkorg AND
              a~vtweg IN so_vtweg AND
              a~vkbur EQ lv_vkbur AND
            ( a~auart LIKE 'ZO%' OR a~auart LIKE 'ZR%' OR
              a~auart LIKE 'ZT%' OR a~auart LIKE 'ZA%' OR
              a~auart LIKE 'ZD%' OR a~auart LIKE 'YO%' OR
              a~auart LIKE 'YR%' OR a~auart LIKE 'YA%' ) AND
              a~vbeln EQ i_key-vbeln AND
              a~vkgrp IN so_vkgrp AND
              a~kunnr IN so_kunnr AND
              a~audat IN so_audat AND
              a~erdat IN so_erdat AND
              a~lifsk EQ 'Z1'.
*               C~CMGST Ne 'B'      and
*               ( C~BESTK EQ ' ' OR  C~BESTK EQ 'C' )
*               ( C~BESTK Ne 'A' OR C~BESTK Ne 'B' )
*               order by a~vbeln
*               %_HINTS DB6 'USE_OPTLEVEL 0'.
    IF sy-subrc EQ 0.
      i_itab2[] = i_itab3[].
      SORT i_itab2 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM i_itab2 COMPARING kunnr.
      SELECT kunnr INTO CORRESPONDING FIELDS OF TABLE lt_kunnr FROM knvv
        FOR ALL ENTRIES IN i_itab2
        WHERE kunnr = i_itab2-kunnr AND
              vkbur = pa_vkbur  AND
              vkorg = pa_vkorg.
      IF sy-subrc EQ 0.
        LOOP AT lt_kunnr. " INTO wa_kunnr.
          LOOP AT i_itab3 INTO wa_itab1 WHERE kunnr = lt_kunnr-kunnr.
            wa_itab1-vkbur = pa_vkbur.
            APPEND wa_itab1 TO i_itab1.
            CLEAR wa_itab1.
          ENDLOOP.
        ENDLOOP.
      ELSE.
        REFRESH: i_itab3.
      ENDIF.
      REFRESH: lt_kunnr, i_itab3, i_itab2.
    ENDIF.
  ENDIF.

  SORT i_itab1 BY netwr kunnr vbeln.
  IF i_itab1[] IS INITIAL.
    sy-subrc = 4.
    MESSAGE s000(zs) WITH 'Data Not Found'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_write_column_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_column_header.
  WRITE: / sy-uline(panjang).
  c1 = 1.
  WRITE: / sy-vline. c1 = c1 + 1.
  WRITE AT c1(w1)  'ChBox' NO-GAP  CENTERED.  c1 = c1 + w1.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) 'Document No,' NO-GAP  CENTERED.   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) 'Customer Code' NO-GAP  CENTERED.   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4)  'Customer Name' NO-GAP  CENTERED. c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)  'Value Sales Order' NO-GAP  CENTERED. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  'Doc Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  WRITE AT c1(w6)  'PO. Exp.Date' NO-GAP CENTERED. c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  IF pa_mini = 'X'.
    WRITE AT c1(w7)  'Keterangan' NO-GAP CENTERED. c1 = c1 + w7.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

    WRITE AT c1(1)  ' ' NO-GAP  CENTERED.
    c1 = c1 + 1.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
  WRITE: / sy-uline(panjang).
  c1 = 1.
ENDFORM.                    " f_write_column_header
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
  DATA: l_remark(25).
  c1 = 1.
  WRITE: /  sy-vline. c1 = c1 + 3.
  IF wa_itab1-auth = 'X'.
    WRITE AT c1   va_mark AS CHECKBOX NO-GAP CENTERED.
  ENDIF.
  c1 = c1 + w1 - 2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w2) wa_itab1-vbeln NO-GAP  .   c1 = c1 + w2.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w3) wa_itab1-kunnr NO-GAP  .   c1 = c1 + w3.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w4) wa_itab1-name1 NO-GAP  . c1 = c1 + w4.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w5)   wa_itab1-netwr NO-GAP  DECIMALS 0. c1 = c1 + w5.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  wa_itab1-audat NO-GAP . c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  WRITE AT c1(w6)  wa_itab1-bnddt NO-GAP . c1 = c1 + w6.
  WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.

  IF pa_mini = 'X'.
    IF wa_itab1-mini = 'X' AND wa_itab1-auth = 'X'.
      WRITE AT c1(w7)  l_remark INPUT ON NO-GAP. c1 = c1 + w7..
    ELSE.
      WRITE AT c1(w7)  ' ' NO-GAP . c1 = c1 + w7.

    ENDIF.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
    IF wa_itab1-auth = 'X'.
      WRITE AT c1(1)  wa_itab1-mini NO-GAP . c1 = c1 + 1.
    ELSE.
      WRITE AT c1(1)  ' ' NO-GAP . c1 = c1 + 1.
    ENDIF.
    WRITE AT c1(1)   sy-vline NO-GAP. c1 = c1 + 1.
  ENDIF.
ENDFORM.                    " f_write_detail
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header.
  DATA: v_right_header_len   TYPE i. " VALUE 50.   "space for date stamp

  CONSTANTS:
    c_sales(22)  TYPE c VALUE 'Sales Organization  : ',
    c_plant(22)  TYPE c VALUE 'Branch/Sales Office : ',
    c_userid(22) TYPE c VALUE 'User Name           : ',
    c_date(22)   TYPE c VALUE 'Processing Date     : ',
    c_value(22)  TYPE c VALUE 'Authorazation Value : ',
    c_group(22)  TYPE c VALUE 'User Group          : '.
  IF pa_mini = 'X'.
    v_right_header_len = 65.
  ELSE.
    v_right_header_len = 45.
  ENDIF.

  WRITE: / c_sales, pa_vkorg.

  POSITION v_right_header_len.
  WRITE: c_date, sy-datum.

  WRITE: / c_plant, pa_vkbur.

  POSITION v_right_header_len.
  WRITE: c_value, va_zvalue_high DECIMALS 0 CURRENCY 'IDR'.

  WRITE: / c_userid, sy-uname.
  POSITION v_right_header_len.
  WRITE: c_group, va_usrgroup.

ENDFORM.                    " F_WRITE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_ORDER_CHANGE
*&---------------------------------------------------------------------*
FORM f_order_change  USING    fu_vbeln.
  DATA: lv_order_header_in  LIKE bapisdh1,
        lv_order_header_inx LIKE bapisdh1x,
        lt_return           TYPE TABLE OF bapiret2,
        ls_return           TYPE bapiret2.

  lv_order_header_in-name = sy-uname.
  lv_order_header_in-dlv_block = '  '.

  lv_order_header_inx-updateflag = 'U'.
  lv_order_header_inx-name = 'X'.
  lv_order_header_inx-dlv_block = 'X'.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = fu_vbeln
      order_header_in  = lv_order_header_in
      order_header_inx = lv_order_header_inx
    TABLES
      return           = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE e000(zs) WITH ls_return-message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.                    " F_ORDER_CHANGE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_USER_GROUP
*&---------------------------------------------------------------------*
FORM f_validasi_user_group .
  DATA : ls_usrgrp  LIKE LINE OF gt_usrgrp.

  SELECT *
    FROM usgrp_user
    INTO CORRESPONDING FIELDS OF TABLE gt_usrgrp
    WHERE bname  = sy-uname.

  LOOP AT gt_usrgrp INTO ls_usrgrp.
    CASE ls_usrgrp-usergroup.
      WHEN 'BM'.
        CONCATENATE va_usrgroup 'BM' INTO va_usrgroup
        SEPARATED BY space.
      WHEN 'BSM'.
        CONCATENATE va_usrgroup 'BSM' INTO va_usrgroup
        SEPARATED BY space.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
  CONDENSE: va_usrgroup.
  IF va_usrgroup(2) = 'BM' OR va_usrgroup(3) = 'BSM'.
  ELSE.
**  IF va_usrgroup IS NOT INITIAL.
    MESSAGE e002(zz) WITH 'Khusus User Group' va_usrgroup.
  ENDIF.
ENDFORM.                    " F_VALIDASI_USER_GROUP
