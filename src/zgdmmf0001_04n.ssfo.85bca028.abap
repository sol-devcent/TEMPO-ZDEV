IF wa_hd-name1_plants CS 'QQ'.
va_pos = sy-fdpos + 2.
va_imported = wa_hd-name1_plants+va_pos.
SHIFT va_imported LEFT DELETING LEADING space.
ELSE.
va_imported = wa_hd-name1_plants.
ENDIF.






















