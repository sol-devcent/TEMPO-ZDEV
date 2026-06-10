*----------------------------------------------------------------------*
***INCLUDE LZTKMSDDT002I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TABLE_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE table_modify INPUT.
*{   INSERT         P01K910034                                        2
* start deleted SOH: Shell SCI Adjustment 20240220 KRS
*}   INSERT
*{   DELETE         P01K910034                                        1
*\  SELECT SINGLE ktext ltext
*\    FROM cepct
*\    INTO (ztkmsddt002-ktext, ztkmsddt002-ltext)
*\    WHERE spras = sy-langu
*\      AND prctr = ztkmsddt002-prctr
*\      AND datbi >= sy-datum
*\      AND kokrs = '8010'.
*\
*\  SELECT SINGLE name1
*\    FROM lfa1
*\    INTO ztkmsddt002-name1
*\    WHERE lifnr = ztkmsddt002-lifnr.
*}   DELETE
*{   INSERT         P01K910034                                        3
* end deleted SOH: Shell SCI Adjustment 20240220 KRS
*}   INSERT
ENDMODULE.                 " TABLE_MODIFY  INPUT
