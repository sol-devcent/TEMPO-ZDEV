

CLEAR WAD_DT.

**** Change Request to display
**** customer code for kmm do intercompany
**** by iway
data: lv_likp TYPE likp.
data: li_lips type STANDARD TABLE OF lips WITH HEADER LINE.
data: lv_ekko TYPE ekko.
data: lv_ekpv TYPE ekpv.
data: lv_ebeln TYPE ebeln.
data: lv_kna1 TYPE kna1.
DATA: LI_LINE TYPE STANDARD TABLE OF TLINE WITH HEADER LINE.
DATA: LV_ID TYPE THEAD-TDID VALUE 'F01'.
DATA: LV_NAME TYPE THEAD-TDNAME.
DATA: LV_OBJECT TYPE THEAD-TDOBJECT VALUE 'EKKO'.

CLEAR: VA_VSTEL, VA_KUNNR, VA_NAME1.

SELECT SINGLE * INTO lv_likp
  from likp WHERE vbeln = wa_hd-VBELN
  .
if sy-subrc eq 0 and lv_likp-vstel = '3600'.
  VA_VSTEL = LV_LIKP-VSTEL.

  SELECT * INTO TABLE li_lips
    from lips WHERE vbeln = wa_hd-vbeln
    .

  if sy-subrc eq 0.
    LOOP at li_lips where VGBEL is NOT INITIAL.
       SELECT SINGLE * INTO LV_EKKO
         FROM EKKO WHERE ebeln = li_lips-vgbel.

         if sy-subrc eq 0.
           LV_NAME = LV_EKKO-EBELN.
           CALL FUNCTION 'READ_TEXT'
             EXPORTING
               id                            = LV_ID
               language                      = SY-LANGU
               name                          = LV_NAME
               object                        = LV_OBJECT
             tables
               lines                         = LI_LINE
            EXCEPTIONS
              ID                            = 1
              LANGUAGE                      = 2
              NAME                          = 3
              NOT_FOUND                     = 4
              OBJECT                        = 5
              REFERENCE_CHECK               = 6
              WRONG_ACCESS_TO_ARCHIVE       = 7
              OTHERS                        = 8
                     .
           IF sy-subrc <> 0.

           ELSE.
             READ TABLE LI_LINE INDEX 1.
             IF SY-SUBRC EQ 0.
               lv_ebeln = LI_LINE-TDLINE.
               SELECT SINGLE * INTO lv_ekpv from ekpv
                 WHERE ebeln = lv_ebeln and kunnr ne ''
                 .
               if sy-subrc eq 0.
                 SELECT SINGLE * INTO lv_kna1
                   from kna1 WHERE kunnr =  lv_ekpv-kunnr.
                 IF SY-SUBRC EQ 0.
                   VA_KUNNR = LV_KNA1-KUNNR.
                   VA_NAME1 = LV_KNA1-NAME1.
                   EXIT.
                 ENDIF.
               endif.
             ENDIF.
           ENDIF.
         ENDIF.
     ENDLOOP.
  endif.
ENDIF.

**** End Change Request


















