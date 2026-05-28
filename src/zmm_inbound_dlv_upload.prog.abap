REPORT ZMM_INBOUND_DLV_UPLOAD.
************************************************************************
*                REPORT                                                *
*----------------------------------------------------------------------*
* ABAP Name   : ZMM_INBOUND_DLV_UPLOAD                                 *
* Created by  : Mahendro K                                             *
* Created on  : 21 May 2015                                            *
* Version     : 1.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description : Upload Inbound Delivery for TNT Import Department      *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
* Revised     :
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF t_excel,
    row         LIKE zalsmex_tabline-row,
    col         LIKE zalsmex_tabline-col,
    value       LIKE zalsmex_tabline-value,
  END OF t_excel,

  BEGIN OF t_fileuser,
     POPRC      like EKPO-BEDNR, "PO Number Principal
     TNTIV      like LIKP-VERUR, "TNT Invoice Number
     INVNO      like EIKP-PRONU, "Invoice Number Principal
     INVDT      like EIKP-PRODA, "Invoice Date Principal
     BOLNR      like LIKP-BOLNR, "Bill Of Lading
     ETA        like LIKP-LFDAT, "ETA
     MTPRC      like MARA-BISMT, "Material Code Principal
     MENGE      like LIPS-LFIMG, "Quantity
     MDESC(80), "Material Description
  END OF t_fileuser,

  BEGIN OF t_inb_dlv,
     BEDNR      like EKPO-BEDNR, "PO Number Principal
     VERUR      like LIKP-VERUR, "TNT Invoice Number
     PRONU      like EIKP-PRONU, "Invoice Number Principal
     PRODA      like EIKP-PRODA, "Invoice Date Principal
     BOLNR      like LIKP-BOLNR, "Bill Of Lading
     LFDAT      like LIKP-LFDAT, "ETA
     BISMT      like MARA-BISMT, "Material Code Principal
     EBELN      like EKPO-EBELN, "PO SAP
     EBELP      like EKPO-EBELP, "PO Item
     MATNR      like EKPO-MATNR, "Material Code SAP
     MENGE      like LIPS-LFIMG, "Quantity
     MEINS      like LIPS-MEINS, "UoM
     WERKS      like LIPS-WERKS, "Plant
     LGORT      like LIPS-LGORT, "Sloc
  END OF t_inb_dlv,

  BEGIN OF t_bednr,
     BEDNR      like EKPO-BEDNR, "PO Number Principal
  END OF t_bednr,

  BEGIN OF t_pronu,
     PRONU      like EIKP-PRONU, "Invoice Number Principal
  END OF t_pronu,

  BEGIN OF t_jde,
     MATNR      like MEAN-MATNR,
     EAN11      like MEAN-EAN11,
  END OF t_jde.

FIELD-SYMBOLS: <lfs_inb_dlv> TYPE t_inb_dlv.

DATA:
    i_excel     TYPE t_excel OCCURS 0,
    wa_excel    TYPE t_excel,
    i_fileuser  TYPE t_fileuser OCCURS 0,
    wa_fileuser TYPE t_fileuser,
    i_inb_dlv   TYPE t_inb_dlv OCCURS 0.

DATA: IS_INB_DELIVERY_HEADER LIKE BBP_INBD_L,
      T_DETAIL LIKE BBP_INBD_D OCCURS 0 WITH HEADER LINE,
      lt_xeikp like eikpvb occurs 0 with header line,
      lt_xeipo like eipovb occurs 0 with header line.

Data: L_T_RETURN  like BAPIRETURN occurs 0 with header line.

DATA: L_ERROR_FOUND Type C,
      TXTMSG(160)   Type C,
      V_VBELN TYPE VBELN_VL,
      D_EXNUM TYPE EIKP-EXNUM.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
Parameters FILE_I LIKE RLGRAP-FILENAME OBLIGATORY. "File data
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK NOTES WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN COMMENT 1(60) TEXT-003.
SELECTION-SCREEN END   OF BLOCK NOTES.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILE_I.
  PERFORM CALL_FILE USING FILE_I.

START-OF-SELECTION.
  PERFORM f_get_data using FILE_I.
  PERFORM f_validate_data.
  CHECK L_ERROR_FOUND = ''. "Do not post if there are any error
  PERFORM f_posting_data.

*---------------------------------------------------------------------*
*       FORM CALL_FILE                                                *
*---------------------------------------------------------------------*
*  -->  FILENAME                                                      *
*---------------------------------------------------------------------*
FORM CALL_FILE USING FILENAME.
  DATA : V_REPID LIKE SY-REPID.

  CALL FUNCTION 'F4_FILENAME'
       EXPORTING
            PROGRAM_NAME  = V_REPID
            DYNPRO_NUMBER = SYST-DYNNR
            FIELD_NAME    = 'PATH'
       IMPORTING
            FILE_NAME     = FILENAME.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*  -->  FILENAME                                                      *
*---------------------------------------------------------------------*
FORM f_get_data USING FILENAME.
  DATA : offset1 like sy-fdpos,
         itab    TYPE TABLE OF string,
         text TYPE string.

  text = FILENAME.

* Get filename, extract from full path name
  SPLIT text AT '\' INTO TABLE itab.
  LOOP at itab into text.
    if text cs '.xls'.
       offset1 = sy-fdpos.
       text = text(offset1).
    endif.
  endloop.

  REFRESH i_excel.
* GET DATA FROM EXCEL FILE.
  CALL FUNCTION 'Z_ALSM_EXCEL_TO_INTERNAL_TABLE'
       EXPORTING
            filename =
               FILENAME "INPUT FROM SELECTION SCREEN
            i_begin_col             = 1
            i_begin_row             = 2
            i_end_col               = 16
            i_end_row               = 60000
       TABLES
            intern                  = i_excel
       EXCEPTIONS
            inconsistent_parameters = 1
            upload_ole              = 2
            OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR i_fileuser.
  CLEAR wa_excel.

  sort i_excel by row col value.
  LOOP AT i_excel INTO wa_excel.
*    if wa_excel-col = '0001'.
*       move wa_excel-value to wa_fileuser-tntiv.
*    endif.
    wa_fileuser-tntiv = text.
    if wa_excel-col = '0001'. "Invoice Number
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
                 EXPORTING
                      I_INPUT      = wa_excel-value
                 IMPORTING
                      E_OUTPUT     = wa_fileuser-invno.
*      move wa_excel-value to wa_fileuser-invno.
    endif.
    if wa_excel-col = '0002'. "Invoice Date
      PERFORM CONVERT_DATE USING wa_excel-value
                                 wa_fileuser-invdt.
    endif.
    if wa_excel-col = '0003'. "Bill of Lading
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
                 EXPORTING
                      I_INPUT      = wa_excel-value
                 IMPORTING
                      E_OUTPUT     = wa_fileuser-bolnr.
*      move wa_excel-value to wa_fileuser-bolnr.
    endif.
    if wa_excel-col = '0004'. "ETA
      PERFORM CONVERT_DATE USING wa_excel-value
                                 wa_fileuser-eta.
    endif.
    if wa_excel-col = '0005'.
    CALL FUNCTION 'AIPC_CONVERT_TO_UPPERCASE'
                 EXPORTING
                      I_INPUT      = wa_excel-value
                 IMPORTING
                      E_OUTPUT     = wa_fileuser-poprc.
*      move wa_excel-value to wa_inb_dlv-poprc.
    endif.
    if wa_excel-col = '0006'.
       move wa_excel-value to wa_fileuser-mtprc.
       CONDENSE wa_fileuser-mtprc NO-GAPS.
    endif.
    if wa_excel-col = '0007'. "Product Description
       move wa_excel-value to wa_fileuser-mdesc.
    endif.
*    if wa_excel-col = '0008'. "Packaging
*    endif.
    if wa_excel-col = '0009'. "Quantity
      move wa_excel-value to wa_fileuser-MENGE.
    endif.

    AT end of  ROW.
      APPEND wa_fileuser TO i_fileuser.
      CLEAR  wa_fileuser.
    ENDAT.
    CLEAR wa_excel.
  ENDLOOP.

  CHECK i_fileuser is not initial.
* Tidak boleh ada data yang cacat
  LOOP at i_fileuser into wa_fileuser.
    IF wa_fileuser-invno eq space.
       message e002(zz) with 'Ada data yang no Invoice Number nya blank'.
    ENDIF.
    IF wa_fileuser-invdt eq '00000000'.
       message e002(zz) with 'Ada data yang no Invoice date nya blank'.
    ENDIF.
    IF wa_fileuser-bolnr eq space.
       message e002(zz) with 'Ada data yang no Bil of Lading nya blank'.
    ENDIF.
    IF wa_fileuser-eta eq '00000000'.
       message e002(zz) with 'Ada data yang no ETA nya blank'.
    ENDIF.
    IF wa_fileuser-poprc eq space.
       message e002(zz) with 'Ada data yang no PO nya blank'.
    ENDIF.
    IF wa_fileuser-menge eq space.
       message e002(zz) with 'Ada data yang no Qty nya blank'.
    ENDIF.
  ENDLOOP.

  SORT i_fileuser by POPRC MTPRC.

* Get SAP PO data
  SELECT EBELN EBELP BEDNR EKPO~MATNR MENGE EKPO~MEINS WERKS LGORT BISMT
    FROM EKPO JOIN MARA
    ON MARA~MATNR = EKPO~MATNR
    INTO CORRESPONDING FIELDS OF TABLE i_inb_dlv
    FOR ALL ENTRIES IN i_fileuser
    WHERE BEDNR = i_fileuser-poprc
      AND LOEKZ = ''.

  SELECT EBELN EBELP BEDNR EKPO~MATNR MENGE EKPO~MEINS WERKS LGORT BISMT
    FROM EKPO JOIN MARA
    ON MARA~MATNR = EKPO~MATNR
    APPENDING CORRESPONDING FIELDS OF TABLE i_inb_dlv
    FOR ALL ENTRIES IN i_fileuser
    WHERE EBELN = i_fileuser-poprc
      AND LOEKZ = ''.

  LOOP at i_inb_dlv ASSIGNING <lfs_inb_dlv>.
    IF <lfs_inb_dlv>-bednr eq space.
       <lfs_inb_dlv>-bednr = <lfs_inb_dlv>-ebeln.
    ENDIF.
  ENDLOOP.
  IF i_inb_dlv is initial.
     message e002(zz) with 'Nomor PO salah, tolong dicek'.
  ENDIF.
  SORT i_inb_dlv by BEDNR BISMT.
ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_VALIDATE_DATA .
  DATA: i_bednr1  TYPE t_bednr OCCURS 0,
        i_bednr2  TYPE t_bednr OCCURS 0,
        wa_bednr1 TYPE t_bednr,
        wa_bednr2 TYPE t_bednr,
        i_pronu   TYPE t_pronu OCCURS 0,
        wa_pronu  TYPE t_pronu,
        i_filetmp TYPE t_fileuser OCCURS 0,
        i_jde     TYPE t_jde OCCURS 0,
        wa_jde    TYPE t_jde,
        count1    TYPE i,
        count2    TYPE i.

    i_filetmp[] = i_fileuser[].
    SORT i_filetmp by mtprc.
    DElETE ADJACENT DUPLICATES FROM i_filetmp COMPARING mtprc.
    LOOP at i_filetmp into wa_fileuser.
      concatenate 'J' wa_fileuser-mtprc into wa_fileuser-mtprc.
      modify i_filetmp from wa_fileuser.
    ENDLOOP.

    select matnr ean11 from mean into table i_jde
    for all entries in i_filetmp
    where ean11 = i_filetmp-mtprc.

    Loop at i_jde into wa_jde.
      wa_jde-ean11 = wa_jde-ean11+1(17).
      modify i_jde from wa_jde.
    Endloop.
    Sort i_jde by ean11.

* Cek apakah ada PO yang tidak ada di SAP
    i_bednr1[] = i_fileuser[].
    SORT i_bednr1 by bednr.
    DElETE ADJACENT DUPLICATES FROM i_bednr1 COMPARING bednr.
    i_bednr2[] = i_inb_dlv[].
    SORT i_bednr2 by bednr.
    DElETE ADJACENT DUPLICATES FROM i_bednr2 COMPARING bednr.
    count1 = lines( i_bednr1 ).
    count2 = lines( i_bednr2 ).
* Ada PO yang tidak ada di SAP, cari sampai ketemu
    IF count1 > count2.
       LOOP at i_bednr1 into wa_bednr1.
         READ TABLE i_bednr2 into wa_bednr2
         WITH KEY BEDNR = wa_bednr1-bednr
         BINARY SEARCH.
         IF SY-SUBRC <> 0.
            Select single bednr from ekpo into wa_bednr2
              where ebeln = wa_bednr1-bednr.
            IF SY-SUBRC <> 0.
            Concatenate 'PO' wa_bednr1-bednr 'is not found in SAP'
            into TXTMSG SEPARATED by SPACE.
            Write TXTMSG.
            L_ERROR_FOUND = 'X'.
            ENDIF.
         ENDIF.
       ENDLOOP.
    ENDIF.

* Cek material code
    LOOP at i_fileuser into wa_fileuser.
      SORT i_inb_dlv by BEDNR BISMT.
      READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
      WITH KEY BEDNR = wa_fileuser-poprc
               BISMT = wa_fileuser-mtprc
      BINARY SEARCH.
      IF SY-SUBRC <> 0.
         READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
         WITH KEY BEDNR = wa_fileuser-poprc
                  BISMT(9) = wa_fileuser-mtprc(9)
         BINARY SEARCH.
         IF SY-SUBRC <> 0.
            READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
            WITH KEY BEDNR = wa_fileuser-poprc
                     BISMT(8) = wa_fileuser-mtprc(8)
            BINARY SEARCH.
            IF SY-SUBRC <> 0.
               READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
               WITH KEY BEDNR = wa_fileuser-poprc
                        BISMT(7) = wa_fileuser-mtprc(7)
               BINARY SEARCH.
               IF SY-SUBRC <> 0.
                  READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
                  WITH KEY BEDNR = wa_fileuser-poprc
                           BISMT(6) = wa_fileuser-mtprc(6)
                  BINARY SEARCH.
                  IF SY-SUBRC <> 0.
                     SORT i_inb_dlv by EBELN MATNR.
                     READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
                     WITH KEY EBELN = wa_fileuser-poprc
                              MATNR = wa_fileuser-mtprc
                     BINARY SEARCH.
                     IF SY-SUBRC <> 0.
                        READ TABLE i_jde INTO wa_jde
                        WITH KEY ean11 = wa_fileuser-mtprc
                        BINARY SEARCH.
                        IF SY-SUBRC = 0.
                           READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
                           WITH KEY EBELN = wa_fileuser-poprc
                           MATNR  = wa_jde-matnr
                           BINARY SEARCH.
                           IF SY-SUBRC <> 0.
                        READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
                        WITH KEY BEDNR = wa_fileuser-poprc
                        BINARY SEARCH.
                        Concatenate 'Material' wa_fileuser-mtprc
                        into TXTMSG SEPARATED by SPACE.
                        TXTMSG+22(80) = wa_fileuser-mdesc.
                        TXTMSG+102(5) = 'in PO'.
                        Concatenate TXTMSG  wa_fileuser-poprc 'is not found in SAP PO' <lfs_inb_dlv>-ebeln
                        into TXTMSG SEPARATED by SPACE.
                         Write TXTMSG.
                         L_ERROR_FOUND = 'X'.
                           ENDIF.
                        ELSE.
                        READ TABLE i_inb_dlv ASSIGNING <lfs_inb_dlv>
                        WITH KEY BEDNR = wa_fileuser-poprc
                        BINARY SEARCH.
                    Concatenate 'Material' wa_fileuser-mtprc
                    into TXTMSG SEPARATED by SPACE.
                    TXTMSG+22(80) = wa_fileuser-mdesc.
                    TXTMSG+102(5) = 'in PO'.
                    Concatenate TXTMSG  wa_fileuser-poprc 'is not found in SAP PO' <lfs_inb_dlv>-ebeln
                    into TXTMSG SEPARATED by SPACE.
                     Write TXTMSG.
                     L_ERROR_FOUND = 'X'.
                     ENDIF.
                     ENDIF.
                  ENDIF.
               ENDIF.
            ENDIF.
         ENDIF.
      ENDIF.

      CHECK L_ERROR_FOUND = ''. "Stop if there are any error
      IF SY-SUBRC = 0.
         <lfs_inb_dlv>-verur = wa_fileuser-tntiv.
         <lfs_inb_dlv>-pronu = wa_fileuser-invno.
         <lfs_inb_dlv>-proda = wa_fileuser-invdt.
         <lfs_inb_dlv>-bolnr = wa_fileuser-bolnr.
         <lfs_inb_dlv>-lfdat = wa_fileuser-eta.
         <lfs_inb_dlv>-menge = wa_fileuser-menge.
      ENDIF.
    ENDLOOP.

* Prepare upload data, delete PO item which are not exist in the file
    SORT i_inb_dlv by pronu proda bolnr ebeln ebelp.
    DELETE i_inb_dlv where pronu is initial.

    check i_inb_dlv is not initial.
    select pronu from eikp into table i_pronu
      for all entries in i_inb_dlv
      where pronu = i_inb_dlv-pronu.
    if sy-subrc = 0.
       loop at i_pronu into wa_pronu.
          Concatenate 'Invoice nomer :' wa_pronu-pronu 'already exist' into TXTMSG SEPARATED by
          SPACE.
          Write TXTMSG.
          L_ERROR_FOUND = 'X'.
       endloop.
       exit.
    endif.

endform.                    " F_VALIDATE_DATA

*---------------------------------------------------------------------*
*       FORM CONVERT_DATE                                             *
*---------------------------------------------------------------------*
*  -->  I_DATE                                                        *
*  <--  E_DATE                                                        *
*---------------------------------------------------------------------*
FORM CONVERT_DATE USING I_DATE LIKE zalsmex_tabline-value
                        E_DATE LIKE SY-DATUM.

  Concatenate I_DATE+6(4) I_DATE+3(2) I_DATE(2) into E_DATE.
ENDFORM.                    " CONVERT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_POSTING_DATA .
DATA : d_verur like likp-verur.

  Clear TXTMSG.
  Clear d_verur.

  Loop at i_inb_dlv assigning <lfs_inb_dlv>.
    If d_verur <> <lfs_inb_dlv>-verur.
       d_verur = <lfs_inb_dlv>-verur.
       If T_DETAIL[] is not initial.
          PERFORM BAPI_PROCESS.
       Endif.
       IS_INB_DELIVERY_HEADER-DELIV_EXT  = <lfs_inb_dlv>-verur. "External ID in Administration tab
       IS_INB_DELIVERY_HEADER-DELIV_DATE = <lfs_inb_dlv>-lfdat.
       IS_INB_DELIVERY_HEADER-BILLOFLAD  = <lfs_inb_dlv>-bolnr.
       CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
          NR_RANGE_NR = '01'
          OBJECT      = 'EXPIMP'
       IMPORTING
          NUMBER      = D_EXNUM.
       lt_xeikp-exnum = D_EXNUM.
       lt_xeikp-aland = 'ID'.
       lt_xeikp-pronu = <lfs_inb_dlv>-pronu.
       lt_xeikp-proda = <lfs_inb_dlv>-proda.
       lt_xeikp-UPDKZ = 'I'.
       append lt_xeikp.
    Endif.
    T_DETAIL-MATERIAL  = <lfs_inb_dlv>-matnr.
    T_DETAIL-DELIV_QTY = <lfs_inb_dlv>-menge.
    T_DETAIL-UNIT      = <lfs_inb_dlv>-meins.
    T_DETAIL-PO_NUMBER = <lfs_inb_dlv>-ebeln.
    T_DETAIL-PO_ITEM   = <lfs_inb_dlv>-ebelp.
    APPEND T_DETAIL.
  Endloop.
* Last Record
  PERFORM BAPI_PROCESS.
endform.                    " F_POSTING_DATA
*&---------------------------------------------------------------------*
*&      Form  BAPI_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form BAPI_PROCESS.
** Call BAPI Function
* Prepare export import data
          call function 'EXPIMP_POSTING' in update task
            tables
              fxeikp = lt_xeikp
              fxeipo = lt_xeipo.

          CALL FUNCTION 'BBP_INB_DELIVERY_CREATE'
          EXPORTING
            is_inb_delivery_header = is_inb_delivery_header
          IMPORTING
            EF_DELIVERY = V_VBELN
          tables
            it_inb_delivery_detail = T_DETAIL
            return = L_T_RETURN.
          L_ERROR_FOUND = ' '.

          LOOP AT L_T_RETURN.
            IF L_T_RETURN-TYPE  = 'E'.
              L_ERROR_FOUND = 'X'.
              Write L_T_RETURN-MESSAGE.
            ENDIF.
          ENDLOOP.

          IF L_ERROR_FOUND = 'X'.
            ROLLBACK WORK.
          ELSE.
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
            Update likp set exnum = D_EXNUM where VBELN = V_VBELN.
            COMMIT WORK AND WAIT.
             Concatenate 'DN nomer :' V_VBELN 'created' into TXTMSG SEPARATED by
            SPACE.
            Write TXTMSG.
          ENDIF.

          CLEAR   : D_EXNUM, V_VBELN, IS_INB_DELIVERY_HEADER, L_T_RETURN.
          REFRESH : T_DETAIL, lt_xeikp, L_T_RETURN.
endform.                    " BAPI_PROCESS
