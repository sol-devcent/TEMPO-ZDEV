*SELECT SINGLE labst
*  FROM mard
*  INTO va_labst
*  WHERE matnr EQ wa_resb-matnr AND
*        werks EQ wa_resb-werks AND
*        lgort EQ wa_resb-lgort.

SELECT SINGLE clabs
  FROM zm_mch1f
  INTO va_labst
  WHERE matnr EQ wa_resb-matnr AND
        werks EQ wa_resb-werks AND
        lgort EQ wa_resb-lgort AND
        charg EQ wa_resb-charg.

IF sy-subrc NE 0.
  SELECT SINGLE labst
    FROM mard
    INTO va_labst
    WHERE matnr EQ wa_resb-matnr AND
          werks EQ wa_resb-werks AND
          lgort EQ wa_resb-lgort.
ENDIF.

WRITE va_labst TO va_labst1 UNIT wa_resb-einheit.
SELECT SINGLE mtart
  FROM mara
  INTO va_mtart
  WHERE matnr EQ wa_resb-matnr.

break bcdik.

IF va_mtart EQ 'ZNS' OR
   va_mtart EQ 'ZSPR' OR
   va_mtart EQ 'ZNV'.
   va_flag = 0.
 ELSE.
   va_flag = 1.
 ENDIF.






















