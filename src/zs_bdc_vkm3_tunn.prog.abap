REPORT zse_release MESSAGE-ID zs NO STANDARD PAGE  HEADING
                                  LINE-COUNT 60(3)
                                  LINE-SIZE  200.


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
TABLES: vbak,
        knkk,
        vbap,
        kna1,
        s066,
        s067,
        vbuk,
        vbkd,
        tvkbz,
        tvkbt,
        usgrp_user,
*        ZSCL_USRGRP,
        zscl_class,
        zscl_range,
        zscl_user,
        zscl_top.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES : BEGIN OF t_credit,
            vkorg  LIKE vbak-vkorg,
            vkbur  LIKE vbak-vkbur,
            knkli  LIKE vbak-knkli,
            kkber  LIKE vbak-kkber,
            vbeln  LIKE vbuk-vbeln,
            erdat  LIKE vbak-erdat,
            audat  LIKE vbak-audat,
END OF t_credit.

************************************************************************
* STRUCTURES & INTERNAL TABLES                                         *
************************************************************************
TYPES:   BEGIN OF t_bdc.
        INCLUDE STRUCTURE bdcdata.
TYPES:   END OF t_bdc.

TYPES:   BEGIN OF t_messtab.
        INCLUDE STRUCTURE bdcmsgcoll.
TYPES:   END OF t_messtab.
TYPES : BEGIN OF t_key,
          vbeln  LIKE vbuk-vbeln,
        END OF t_key.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
*constants :

************************************************************************
* VARIABLES                                                            *
************************************************************************
DATA: wa_credit TYPE t_credit,
      i_credit  TYPE t_credit OCCURS 0,
      i_delete  TYPE t_credit OCCURS 0 WITH HEADER LINE,
      va_nou   TYPE i,
      vkbur LIKE tvkbz-vkbur,
      sw(1),
      i_key TYPE t_key OCCURS 0,
      wa_key TYPE t_key.
.

DATA:
       v_line_size TYPE i,
       v_line_size_sum TYPE i,
       c1    TYPE i,
       c2    TYPE i,
       c3    TYPE i,
       c4    TYPE i,
       w1    TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5    TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       w9    TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
       w13   TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
       w17   TYPE i,  w18   TYPE i,  w19   TYPE i,  w19a  TYPE i,
       w20   TYPE i,  w17a  TYPE i,
       w21   TYPE i,  w22   TYPE i,  w23   TYPE i,  w24   TYPE i,
       w25   TYPE i,  w26   TYPE i,  w27   TYPE i,  w28   TYPE i,
       w29   TYPE i,  w30   TYPE i,  w31   TYPE i,  w32   TYPE i,
       w33   TYPE i,  w34   TYPE i,  w35   TYPE i.

DATA: va_msg(100),
      i_bdc TYPE t_bdc OCCURS 0,
      wa_bdc TYPE t_bdc,
      i_messtab TYPE t_messtab OCCURS 0,
      wa_messtab TYPE t_messtab.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_kkber FOR knkk-kkber OBLIGATORY NO INTERVALS.
PARAMETERS so_vkorg LIKE vbak-vkorg OBLIGATORY DEFAULT '8020'.
PARAMETERS so_vkbur LIKE vbak-vkbur OBLIGATORY .
SELECT-OPTIONS so_knkli FOR knkk-knkli.
SELECT-OPTIONS so_vbeln FOR vbak-vbeln.
*     Select-Options so_audat for vbak-audat.
PARAMETERS pa_range(2) DEFAULT '07'.
PARAMETERS      va_mode DEFAULT 'A'.
SELECTION-SCREEN END OF BLOCK block1.


************************************************************************
* AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN ON so_vkorg.
  IF so_vkorg EQ '8020' OR so_vkorg EQ '8030'
    OR so_vkorg EQ '8070'.
  ELSE.
    MESSAGE e000(zs)
      WITH 'Company Code must be entry (8020, 8030, 8070)'.
  ENDIF.

AT SELECTION-SCREEN ON so_vkbur.
  SELECT vkbur INTO vkbur FROM tvkbz
         WHERE vkbur EQ so_vkbur AND
               vkorg EQ so_vkorg.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'Business Area Not Found'.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
        ID 'VKBUR' FIELD vkbur.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
       so_vkbur.
    ENDIF.
  ENDSELECT.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  so_kkber-low    = '8000'.
  so_kkber-sign   = 'I'.
  so_kkber-option = 'EQ'.
  APPEND so_kkber.
  so_kkber-low    = '8020'.
  so_kkber-sign   = 'I'.
  so_kkber-option = 'EQ'.
  APPEND so_kkber.
  so_kkber-low    = '8070'.
  so_kkber-sign   = 'I'.
  so_kkber-option = 'EQ'.
  APPEND so_kkber.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  DATA: tgl LIKE sy-datum,
        l_field(20),
        l_index_str(3) TYPE c,
        va_ctr TYPE i.


  DATA: ctr TYPE i.
  DATA: l_numki LIKE zsrange-numki_so,
        l_date  LIKE sy-datum,
        l_fromnumber LIKE nriv-fromnumber,
        l_nrlevel  LIKE nriv-nrlevel, l_sw(1).

  tgl = sy-datum - pa_range.

  REFRESH: i_key,  i_credit .
  CLEAR: wa_key, i_key, ctr, i_credit.

* Bila nomer DO kosong, baca tabel number range sesuai cabang
  IF so_vbeln IS INITIAL.
    l_sw = 1.
    CLEAR: l_numki, l_nrlevel, l_fromnumber.
    SELECT SINGLE numki_so FROM zsrange
           INTO l_numki
           WHERE vkbur EQ so_vkbur.
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
*                 ( cmpsb eq 'B' or cmpsg = 'B' ) and
*                ( GBSTK eq 'A' or GBSTK eq 'B' ) and
*                  CMGST eq 'B'                   and
                  vbtyp EQ 'C'                   AND
                  lfgsk EQ 'A'                   AND
                  cmgst EQ 'B'.

  DELETE i_key WHERE NOT ( vbeln IN so_vbeln ).

  DESCRIBE TABLE i_key LINES ctr.
  IF ctr <= 0.
    MESSAGE s000(zs) WITH 'Data Not Found'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SELECT
        a~vkorg
        a~vkbur
        a~kunnr
        a~knkli
        a~kkber
        a~vbeln
        a~netwr
        a~audat
        c~name1
        c~brsch
        e~zterm
        a~auart
        a~kvgr3

        INTO CORRESPONDING FIELDS OF TABLE i_credit
        FROM vbak AS a JOIN kna1 AS c  ON c~kunnr EQ a~knkli
                       JOIN knb1 AS e  ON e~kunnr EQ a~knkli AND
                                          e~bukrs EQ a~vkorg
            FOR ALL ENTRIES IN i_key
        WHERE a~vbeln EQ i_key-vbeln AND
              a~kkber IN so_kkber    AND
              a~knkli IN so_knkli    AND
              a~vkorg EQ so_vkorg    AND
              a~vkbur EQ so_vkbur    AND
              a~audat < tgl.
  IF sy-subrc NE 0.
    MESSAGE s000(zs) WITH 'Data Not Found'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*    select a~vbeln
*           b~vkorg  b~kunnr b~vbeln b~audat b~erdat b~knkli b~kkber
*           b~vkbur
*           INTO CORRESPONDING FIELDS OF TABLE i_credit
*           from vbak as b JOIN vbuk as a  on a~vbeln eq b~vbeln
*           where b~KKBER in so_kkber and
*                 b~KNKLI in so_knkli and
*                 b~vkorg eq so_vkorg and
*                 b~vkbur in so_vkbur and
*                 b~vbeln in so_vbeln and
**                 b~audat in so_audat and
*                 b~AUART ne 'QT' and
*                 a~spstg eq 'C' and
*                 ( a~cmpsb eq 'B' or a~cmpsg = 'B' ) and
*                ( a~GBSTK eq 'A' or a~GBSTK eq 'B' ) and
*                  a~CMGST eq 'B' and
*                  b~audat < tgl
*                order by b~vkorg a~vbeln.
*  if sy-subrc ne 0.  "cmpsg cmpsb
*      message i000(zs) with 'Data Not Found'.
*      Exit.
*  endif.

  CLEAR i_bdc.
  CLEAR: va_ctr, wa_credit, sw.
  LOOP AT i_credit INTO wa_credit.

    APPEND wa_credit TO i_delete.

    ADD 1 TO va_ctr.
    IF va_ctr = 1.
      CLEAR i_bdc.
      PERFORM f_dynpro USING:  'X' 'RVKRED04'     '1000',
                               ' ' 'BDC_OKCODE'   '=%001',
                               'X' 'SAPLALDB'     '3000'.
    ENDIF.
    l_index_str = va_ctr.
    CONDENSE l_index_str.
*    CONCATENATE 'RSCSEL-SLOW_I(0' l_index_str ')' INTO l_field.
    CONCATENATE 'RSCSEL_255-SLOW_I(0' l_index_str ')' INTO l_field.
    PERFORM f_dynpro USING:  ' ' l_field  wa_credit-vbeln.

    WRITE: / wa_credit-vkorg, sy-vline,
             wa_credit-vkbur, sy-vline,
             wa_credit-knkli, sy-vline,
             wa_credit-vbeln, sy-vline,
             wa_credit-audat, sy-vline,
             wa_credit-erdat, sy-vline.
    CLEAR: wa_credit.
    sw = 1.
    IF va_ctr = 8.
      PERFORM f_dynpro USING:  ' ' 'BDC_OKCODE'   '=ACPT',
                               'X' 'RVKRED04'     '1000',
                               ' ' 'BDC_OKCODE'   '=ONLI',
                               'X' 'SAPMSSY0'     '0120',
                               ' ' 'BDC_OKCODE'   '=&ALL',
                               'X' 'SAPMSSY0'     '0120',
                               ' ' 'BDC_OKCODE'   '=ABSA',
                               ' ' 'TVAGT-ABGRU'  '01',
                               'X' 'RVKRED01'     '0201',
                               ' ' 'BDC_OKCODE'   '=UEBE',
                               ' ' 'TVAGT-ABGRU'  '01',
                               'X' 'SAPMSSY0'     '0120',
                               ' ' 'BDC_OKCODE'   '=SAVE',
                               'X' 'SAPMSSY0'     '0120',
                               ' ' 'BDC_OKCODE'   '=BACK',
                               'X' 'SAPMSSY0'     '0120',
                               ' ' 'BDC_OKCODE'   '=&F03',
                               'X' 'SAPLSPO1'     '0100',
                               ' ' 'BDC_OKCODE'   '=YES',
                               'X' 'RVKRED04'     '1000',
                               ' ' 'BDC_OKCODE'   '/EE'.
      CALL TRANSACTION 'VKM3' USING i_bdc MODE va_mode UPDATE 'S'
                MESSAGES INTO i_messtab.
      IF sy-subrc NE 0.
        READ TABLE i_messtab INTO wa_messtab INDEX 1.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id   = wa_messtab-msgid
            lang = wa_messtab-msgspra
            no   = wa_messtab-msgnr
            v1   = wa_messtab-msgv1
            v2   = wa_messtab-msgv2
            v3   = wa_messtab-msgv3
            v4   = wa_messtab-msgv4
          IMPORTING
            msg  = va_msg.
        WRITE: / 'Message Error : ', va_msg.
      ELSE.
        PERFORM f_delete_table_release.
      ENDIF.
      va_ctr = 0.
    ENDIF.
  ENDLOOP.
  IF va_ctr <> 0.
    PERFORM f_dynpro USING:  ' ' 'BDC_OKCODE'   '=ACPT',
                             'X' 'RVKRED04'     '1000',
                             ' ' 'BDC_OKCODE'   '=ONLI',
                             'X' 'SAPMSSY0'     '0120',
                             ' ' 'BDC_OKCODE'   '=&ALL',
                             'X' 'SAPMSSY0'     '0120',
                             ' ' 'BDC_OKCODE'   '=ABSA',
                             ' ' 'TVAGT-ABGRU'  '01',
                             'X' 'RVKRED01'     '0201',
                             ' ' 'BDC_OKCODE'   '=UEBE',
                             ' ' 'TVAGT-ABGRU'  '01',
                             'X' 'SAPMSSY0'     '0120',
                             ' ' 'BDC_OKCODE'   '=SAVE',
                             'X' 'SAPMSSY0'     '0120',
                             ' ' 'BDC_OKCODE'   '=BACK',
                             'X' 'SAPMSSY0'     '0120',
                             ' ' 'BDC_OKCODE'   '=&F03',
                             'X' 'SAPLSPO1'     '0100',
                             ' ' 'BDC_OKCODE'   '=YES',
                             'X' 'RVKRED04'     '1000',
                             ' ' 'BDC_OKCODE'   '/EE'.
    CALL TRANSACTION 'VKM3' USING i_bdc MODE va_mode UPDATE 'S'
              MESSAGES INTO i_messtab.
    IF sy-subrc NE 0.
      READ TABLE i_messtab INTO wa_messtab INDEX 1.
      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id   = wa_messtab-msgid
          lang = wa_messtab-msgspra
          no   = wa_messtab-msgnr
          v1   = wa_messtab-msgv1
          v2   = wa_messtab-msgv2
          v3   = wa_messtab-msgv3
          v4   = wa_messtab-msgv4
        IMPORTING
          msg  = va_msg.
      WRITE: / 'Message Error : ', va_msg.
    ELSE.
      PERFORM f_delete_table_release.
    ENDIF.
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
*&      Form  F_DELETE_TABLE_RELEASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_delete_table_release .
  LOOP AT i_delete.
    DELETE FROM zghsd_tabcli2016 WHERE vkorg = i_delete-vkorg
                                   AND vkbur = i_delete-vkbur
                                   AND vtweg = space
                                   AND kkber = i_delete-kkber
                                   AND knkli = i_delete-knkli
                                   AND vbeln = i_delete-vbeln.
  ENDLOOP.
  CLEAR: i_delete,i_delete[].
ENDFORM.                    " F_DELETE_TABLE_RELEASE
