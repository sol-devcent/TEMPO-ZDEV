REPORT zs_upload_sales NO STANDARD PAGE HEADING MESSAGE-ID 00
                        LINE-SIZE 170.


CONSTANTS:
      c_idoctp LIKE edidc-idoctp VALUE 'ZTIAM_IDOC_TY', "'ZMSGTIAM', "'ZMSGTIAM',
      c_rcvprt LIKE edidc-rcvprt VALUE 'LS',         "Partner type of receiver
      c_sndprt LIKE edidc-sndprt VALUE 'LS'.          "Destination System


DATA : gt_edi_dc40  LIKE edi_dc40 OCCURS 0 WITH HEADER LINE.  "Generated Communication IDOc
DATA : gs_edi_dc40  LIKE edi_dc40. "Idoc Control Record
DATA: gv_filename(14)  TYPE c,
      wa_edidd         TYPE edi_dd40,
       gt_edidd         TYPE STANDARD TABLE OF edi_dd40.   "Data Records
DATA: c_segnam LIKE edi_dd40-segnam.
DATA: t_ztiam_custom TYPE STANDARD TABLE OF ztiam_custom WITH HEADER LINE.

DATA : gv_inputpath LIKE edi_path-pthnam,
      gv_fullfile  LIKE edi_path-pthnam.


SELECTION-SCREEN BEGIN OF BLOCK aaa WITH FRAME TITLE text-aaa.
PARAMETERS :  c_mestyp LIKE edidc-mestyp DEFAULT 'ZMSGTIAM',   "Message Type
              c_rcvprn LIKE edidc-rcvprn DEFAULT 'DEVCLNT800',  "'P01CLNT800', "'DVCLNT130',
              c_rcvpor LIKE edidc-rcvpor DEFAULT 'SAPDEV', "'SAPP01', "ZIT02_VB', "SAPP01800', "'SAPDEV130',
              c_sndprn LIKE edidc-sndprn DEFAULT 'TIAM', "'DEVCLNT800', "ZIT02_VB', "DEVCLNT130',
              c_sndpor LIKE edidc-sndpor DEFAULT 'ZIT02_TIAM'. "ZIT02_TIAM'. "SAPDEV'. "ZISD01_SFA'. "VBTST'. "'SAPDEV130'.
SELECTION-SCREEN SKIP 2.
PARAMETERS :  p_path(125) DEFAULT '\tiam\inbound\' LOWER CASE.
SELECTION-SCREEN SKIP 2.
PARAMETERS :  p_belnr LIKE ztiam_custom-belnr.
PARAMETERS: p_cek AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK aaa.

INITIALIZATION.

START-OF-SELECTION.
  CONDENSE p_path.
  gv_filename = 'Event.txt'.
  CONCATENATE p_path gv_filename INTO gv_fullfile.
  IF p_cek = 'X'.
    gs_edi_dc40-tabnam = 'EDI_DC40_U'.
  ELSE.
    gs_edi_dc40-tabnam = 'EDI_DC40'.
  ENDIF.
  gs_edi_dc40-mandt = sy-mandt.
  gs_edi_dc40-rcvpor = c_rcvpor. "Receiver Port
  gs_edi_dc40-rcvprt = c_rcvprt. "Partner type of receiver
  gs_edi_dc40-rcvprn = c_rcvprn. "Partner number of receiver
  gs_edi_dc40-mestyp = c_mestyp. "Message type
  gs_edi_dc40-idoctyp = c_idoctp. "Basic IDOC type
  gs_edi_dc40-sndprt = c_sndprt. "Sender Partner type
  gs_edi_dc40-sndprn = c_sndprn. "Sender Partner Number
  gs_edi_dc40-sndpor = c_sndpor. "Sender Port
  gs_edi_dc40-direct = '2'.
  gs_edi_dc40-refint = gv_filename.
  APPEND gs_edi_dc40 TO gt_edi_dc40.

  CLEAR wa_edidd.
  c_segnam        = 'ZTIAM_CUSTOM'.
  t_ztiam_custom-belnr = p_belnr. "'ACCEVENT'. "'TIAMIDOC'.
  wa_edidd-segnam  = c_segnam.
  wa_edidd-mandt  = sy-mandt.
  wa_edidd-sdata   = t_ztiam_custom.
  APPEND wa_edidd TO gt_edidd.

  PERFORM f_create_text_file.

  CALL FUNCTION 'EDI_DATA_INCOMING'
    EXPORTING
      pathname = gv_fullfile
      port     = c_sndpor.


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TEXT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_text_file .
  DATA : l_version LIKE edisdef-version,
         l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filedestination(125) TYPE c,
         l_text(1000) TYPE c,
         l_extension(5) TYPE c.
  DATA: tot_rec(4), rec_i TYPE i.

  SPLIT gv_fullfile AT '.' INTO l_filename l_extension.

****  l_filename = 'path dan nama file'.

  CONCATENATE  l_filename '_IDOC' '.' 'EDI'  INTO l_filedestination.

  OPEN DATASET l_filedestination FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
  CLEAR: l_text, tot_rec.

  LOOP AT  gt_edi_dc40 INTO gs_edi_dc40.
    l_text = gs_edi_dc40.
    rec_i = 524.
    TRANSFER l_text TO l_filedestination LENGTH rec_i.
  ENDLOOP.
  CLEAR: l_text.
*  tot_rec =
  DESCRIBE TABLE gt_edidd LINES tot_rec.
  LOOP AT gt_edidd INTO wa_edidd.
    SELECT MAX( DISTINCT  version  ) expleng
          INTO (l_version, tot_rec)
          FROM edisdef
      WHERE segtyp = wa_edidd-segnam
      GROUP BY segtyp version expleng.
      "      GROUP BY version segdef expleng.
    ENDSELECT.
    rec_i = tot_rec.
    rec_i = rec_i + 63.
    l_text = wa_edidd.
    TRANSFER l_text TO l_filedestination LENGTH rec_i.
    CLEAR: l_text.
  ENDLOOP.
  CLOSE DATASET l_filedestination.
  PERFORM f_changefilemode USING l_filedestination.
  gv_inputpath  = gv_fullfile. "Insertion by SAP_DEV02(Tiara)  #DEVK932762  07.09.2012
  gv_fullfile   = l_filedestination.

ENDFORM.                    " F_CREATE_TEXT_FILE

*&---------------------------------------------------------------------*
*&      Form  F_CHANGEFILEMODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_FILEDESTINATION  text
*----------------------------------------------------------------------*
FORM f_changefilemode USING p_file TYPE c.
  DATA : BEGIN OF tabl OCCURS 10,
             line(200),
         END OF tabl,
         l_command(125) TYPE c.

*   change file mod to 777
  CONCATENATE 'chmod 777' p_file INTO l_command SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD l_command
                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                    " F_CHANGEFILEMODE
