TABLES:zsign, zsign_wh.

va_flag = '0'. va_flag1 = '0'.
SELECT SINGLE object_name user_name no_sk
INTO (zobject, zuser_name, zno_sk)
FROM zsign_whs
WHERE s_point EQ wa_hd-vstel AND
kunnr EQ wa_hd-kunnr.
IF sy-subrc NE 0.
va_flag = '0'.
ELSE.
va_flag = '1'.
ENDIF.

SELECT SINGLE object_name user_name no_sk
INTO (zobject1, zuser_name1, zno_sk1)
FROM zsign_wh
WHERE s_point EQ wa_hd-vstel.
IF sy-subrc NE 0.
va_flag1 = '0'.
ELSE.
va_flag1 = '1'.
ENDIF.















