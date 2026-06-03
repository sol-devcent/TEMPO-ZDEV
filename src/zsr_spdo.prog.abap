************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZSR_SPDO                                           *
*  PROGRAM DESC  :  SURAT PENGIRIMAN DO                                *
*  CREATED BY    :  BUDI PRAMONO                                       *
*  CREATED ON    :  07/11/2002 (DMY)                                   *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER       CORRECTION  DESCRIPTION                *
*  ----------  ---------------  ----------  -------------------------  *
*  DD/MM/YYYY  XXXXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXX  *
*                                                                     *
************************************************************************
REPORT ZSR_SPDO MESSAGE-ID ZS
                NO STANDARD PAGE HEADING
                LINE-SIZE 127.

*---------------------------------------------------------------------*
* DEFINITION OF TYPES, DATA & TABLE                                   *
*---------------------------------------------------------------------*
TABLES  :  LIKP, LIPS, VBAK, VBAP, KNA1, TPRIT.

TYPES   :  BEGIN OF T_ITAB1,
             LPRIO  LIKE  LIKP-LPRIO,
             BEZEI  LIKE  TPRIT-BEZEI,
             NAME1  LIKE  KNA1-NAME1,
             KUNNR  LIKE  LIKP-KUNNR,
             VBELN  LIKE  LIKP-VBELN,
             WADAT  LIKE  LIKP-WADAT,
             VGBEL  LIKE  LIPS-VGBEL,
             NETWR  LIKE  VBAK-NETWR,
             MWSBP  LIKE  VBAP-MWSBP,
             VALUE  LIKE  VBAP-MWSBP,
           END OF T_ITAB1.

DATA    :  I_ITAB1 TYPE T_ITAB1 OCCURS 0,
           WA_ITAB1 TYPE T_ITAB1,
           VA_TOTVALUE LIKE  VBAK-NETWR,
           VA_LINE_COUNT TYPE I,
           VA_LINE TYPE I.

CONSTANTS : HEADER(127) VALUE 'SURAT PENGANTAR BARANG (SPGD)'.

*---------------------------------------------------------------------*
* DEFINITION OF PARAMETER & SELECTION                                 *
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
  PARAMETERS  :  P_VKORG LIKE LIKP-VKORG OBLIGATORY DEFAULT '8020',
                 P_VSTEL LIKE LIKP-VSTEL OBLIGATORY DEFAULT '0201'.
SELECTION-SCREEN END OF BLOCK BLOCK1.
SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS  :  S_KUNNR FOR LIKP-KUNNR,
                     S_VBELN FOR LIKP-VBELN,
                     S_WERKS FOR LIKP-WERKS,
                     S_LFDAT FOR LIKP-LFDAT,
                     S_ERDAT FOR LIKP-ERDAT.
SELECTION-SCREEN END OF BLOCK BLOCK2.

*---------------------------------------------------------------------*
* AT LINE SELECTION                                                   *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_VKORG.
  IF P_VKORG NE '8020' AND P_VKORG NE '8030' AND P_VKORG NE '8070'.
    MESSAGE E000(ZS) WITH
      'Sales Organization must be entry (8020, 8030, 8070)'.
  ENDIF.
AT SELECTION-SCREEN ON P_VSTEL.
  IF P_VKORG = '8020' AND P_VSTEL NP '02*'.
    MESSAGE E000(ZS) WITH
      'Shipping Point must be entry "02xx"'.
  ENDIF.
  IF P_VKORG = '8030' AND P_VSTEL NP '03*'.
    MESSAGE E000(ZS) WITH
      'Shipping Point must be entry "03xx"'.
  ENDIF.
  IF P_VKORG = '8070' AND P_VSTEL NP '07*'.
    MESSAGE E000(ZS) WITH
      'Shipping Point must be entry "07xx"'.
  ENDIF.

*----------------------------------------------------------------------*
* INITIALIZATION                                                       *
*----------------------------------------------------------------------*
INITIALIZATION.
   PERFORM F_INIT_ALL.

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM F_GETTING_DATA.
  PERFORM F_WRITE_DATA.
END-OF-SELECTION.

*TOP-OF-PAGE.
*  IF SW = '0'.
*    PERFORM F_WRITE_HEADER.
*  ENDIF.
*
*END-OF-PAGE.
*  IF SW = '0'.
*    PERFORM F_WRITE_FOOTER.
*  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  F_INIT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INIT_ALL.
  REFRESH I_ITAB1.
  CLEAR WA_ITAB1.
  VA_LINE_COUNT = 66.
ENDFORM.                    " F_INIT_ALL

*&---------------------------------------------------------------------*
*&      Form  F_GETTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GETTING_DATA.

  DATA : VA_MWSBP LIKE VBAP-MWSBP.

  SELECT KUNNR VBELN LPRIO WADAT
    FROM LIKP
    INTO CORRESPONDING FIELDS OF TABLE I_ITAB1
    WHERE VKORG = P_VKORG  AND
          VSTEL = P_VSTEL  AND
          KUNNR IN S_KUNNR AND
          VBELN IN S_VBELN AND
          WERKS IN S_WERKS AND
          LFDAT IN S_LFDAT AND
          ERDAT IN S_ERDAT.
  IF SY-SUBRC <> 0.
    MESSAGE I000(ZS) WITH 'Data Not Found'.
  ENDIF.

  CLEAR WA_ITAB1.
  LOOP AT I_ITAB1 INTO WA_ITAB1.

* Select VGBEL
    SELECT SINGLE VGBEL
      FROM LIPS
      INTO WA_ITAB1-VGBEL
      WHERE VBELN = WA_ITAB1-VBELN.
* Select NAME1
    SELECT SINGLE NAME1
      FROM KNA1
      INTO WA_ITAB1-NAME1
      WHERE KUNNR = WA_ITAB1-KUNNR.
* Select BEZEI
    SELECT SINGLE BEZEI
      FROM TPRIT
      INTO WA_ITAB1-BEZEI
      WHERE LPRIO = WA_ITAB1-LPRIO AND
            SPRAS = 'EN'.
* Select MWSBP
    SELECT MWSBP
      FROM VBAP
      INTO VA_MWSBP
      WHERE VBELN = WA_ITAB1-VGBEL.
*      WHERE VBELN = WA_ITAB1-VBELN.
        ADD VA_MWSBP TO WA_ITAB1-MWSBP.
    ENDSELECT.
* Select NETWR
    SELECT SINGLE NETWR
      FROM VBAK
      INTO WA_ITAB1-NETWR
      WHERE VBELN = WA_ITAB1-VGBEL.
* Select NETWR
    WA_ITAB1-VALUE = WA_ITAB1-NETWR + WA_ITAB1-MWSBP.
    MODIFY I_ITAB1 FROM WA_ITAB1.
    CLEAR: VA_MWSBP, WA_ITAB1.

  ENDLOOP.

ENDFORM.                    " F_GETTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_WRITE_DATA.

  DATA:  L_LPRIO(2),
         L_KUNNR LIKE LIKP-KUNNR,
         L_NAME1 LIKE KNA1-NAME1,
         L_TEXT1(4),
         L_TEXT2(6).

  CLEAR: WA_ITAB1, L_LPRIO, L_KUNNR, L_NAME1, L_TEXT1, L_TEXT2,
         VA_TOTVALUE, VA_LINE.
  SORT I_ITAB1 BY KUNNR VBELN.
  LOOP AT I_ITAB1 INTO WA_ITAB1.
    AT FIRST.
      PERFORM F_WRITE_HEADER.
    ENDAT.
    AT NEW KUNNR.
      WRITE WA_ITAB1-LPRIO TO  L_LPRIO.
      L_KUNNR = WA_ITAB1-KUNNR.
      L_NAME1 = WA_ITAB1-NAME1.
    ENDAT.
    WRITE: '|', L_LPRIO, '|',
           L_KUNNR, '|',
           L_NAME1, '|',
           WA_ITAB1-WADAT, '|',
           WA_ITAB1-VBELN, '|',
           WA_ITAB1-VALUE DECIMALS 0 CURRENCY 'IDR', '|',
           L_TEXT1, '|',
           L_TEXT1, '|',
*           L_TEXT1, '|',
           L_TEXT2, '|'.
    CLEAR: L_LPRIO, L_KUNNR, L_NAME1.
    ADD WA_ITAB1-VALUE TO VA_TOTVALUE.
    NEW-LINE.
    ADD 1 TO VA_LINE.
    IF VA_LINE GE VA_LINE_COUNT.
      PERFORM F_WRITE_FOOTER.
      PERFORM F_WRITE_HEADER.
    ENDIF.
    AT END OF KUNNR.
      WRITE: '|',
             6 '|',
            19 '|',
            57 '|',
            70 '|',
            83 '|',
           104 '|',
           111 '|',
           118 '|',
           127 '|'.
      NEW-LINE.
      ADD 1 TO VA_LINE.
    ENDAT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
      PERFORM F_WRITE_END.
  ENDIF.
ENDFORM.                    " F_WRITE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_WRITE_HEADER.
  CLEAR VA_LINE.
  NEW-PAGE.
  WRITE: / HEADER CENTERED.
  WRITE: / 'Nama Pengirim   ', 17 ':', (20) ' ' input on,
          95 'User Name       :', SY-UNAME.
  WRITE: / 'Nomor Kendaraan ', 17 ':', (20) ' ' input on,
          95 'Print Out Date  :', SY-DATUM.
  WRITE: / 'Remarks         ', 17 ':', (50) ' ' input on,
          95 'Page            :', SY-PAGNO.
  WRITE: /17 ':', (50) ' ' input on.
  ULINE.
  WRITE: '|', 'PRI|',
         ' CUSTOMER ', '|',
         '          CUSTOMER NAME            ', '|',
         'DO DATE   ', '|',
         'DO NUMBER ', '|',
         '     DO VALUE     ', '|',
         'CASH', '|',
         'GIRO', '|',
         'SIGN  ', '|'.
*         '   REMARKS  ', '|'.
  ULINE.
  ADD 8 TO VA_LINE.
ENDFORM.                    " F_WRITE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FOOTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_WRITE_FOOTER.
  ULINE.
  WRITE: /23 'Subtotal in page', SY-PAGNO, ':',
          69 VA_TOTVALUE CURRENCY 'IDR'.
  SKIP 2.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          18 'PENGIRIM',
          39 '|',
          47 '|',
          59 'WHS. ADMIN',
          81 '|',
          89 '|',
         102 'FINANCE',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Nama Jelas   :',
          39 '|',
          47 '|',
          48 'Nama Jelas   :',
          81 '|',
          89 '|',
          90 'Nama Jelas   :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Tgl Diterima :',
          39 '|',
          47 '|',
          48 'Tgl Diterima :',
          81 '|',
          89 '|',
          90 'Tgl Diterima :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Jam Diterima :',
          39 '|',
          47 '|',
          48 'Jam Diterima :',
          81 '|',
          89 '|',
          90 'Jam Diterima :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
ENDFORM.                    " F_WRITE_FOOTER
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_WRITE_END.
  ULINE.
  WRITE: /23 'GRAND TOTAL :',
          69 VA_TOTVALUE DECIMALS 0 CURRENCY 'IDR'.
  SKIP 2.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          18 'PENGIRIM',
          39 '|',
          47 '|',
          59 'WHS. ADMIN',
          81 '|',
          89 '|',
         102 'FINANCE',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Nama Jelas   :',
          39 '|',
          47 '|',
          48 'Nama Jelas   :',
          81 '|',
          89 '|',
          90 'Nama Jelas   :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Tgl Diterima :',
          39 '|',
          47 '|',
          48 'Tgl Diterima :',
          81 '|',
          89 '|',
          90 'Tgl Diterima :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
  WRITE: /5  '|',
          6  'Jam Diterima :',
          39 '|',
          47 '|',
          48 'Jam Diterima :',
          81 '|',
          89 '|',
          90 'Jam Diterima :',
         123 '|'.
  WRITE: /5  SY-ULINE(35),
          47 SY-ULINE(35),
          89 SY-ULINE(35).
ENDFORM.                    " F_WRITE_END
