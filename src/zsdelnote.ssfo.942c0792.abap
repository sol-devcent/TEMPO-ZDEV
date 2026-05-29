DATA: ls_likp LIKE likp,
      ls_zfkwiout LIKE zfkwiout.

SELECT SINGLE vbeln vkorg kunnr vkbur
  INTO CORRESPONDING FIELDS OF ls_likp
  FROM likp WHERE vbeln = gs_header-vbelnl.

SELECT SINGLE * INTO ls_zfkwiout
  FROM zfkwiout WHERE bukrs = ls_likp-vkorg
*                  AND vkbur = ls_likp-vkbur
                  AND kunnr = gs_header-kunnr
                  AND zsts  = 'X'.
IF sy-subrc = 0.
  gv_ttf = 'TTF'.
ENDIF.
















