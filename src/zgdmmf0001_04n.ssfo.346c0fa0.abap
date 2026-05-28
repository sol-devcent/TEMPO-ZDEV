DATA: ld_street      LIKE adrc-street,
      ld_str_suppl3  LIKE adrc-str_suppl3,
      ld_city1       LIKE adrc-city1,
      ld_landx       LIKE t005t-landx,
      ld_country     LIKE adrc-country,
      ld_tlp         LIKE adrc-tel_number,
      ld_fax         LIKE adrc-fax_number.

if wa_hd-ekorg eq 'TNT'.
  SELECT SINGLE street city1 str_suppl3 country tel_number fax_number
  FROM t001 JOIN adrc ON t001~adrnr EQ adrc~addrnumber
  INTO (ld_street, ld_city1, ld_str_suppl3, ld_country, ld_tlp, ld_fax)
  WHERE bukrs EQ '8160'.
elseif wa_hd-ekorg eq 'RSF' or wa_hd-ekorg eq 'TLOG'.
  SELECT SINGLE street city1 str_suppl3 country tel_number fax_number
  FROM t001 JOIN adrc ON t001~adrnr EQ adrc~addrnumber
  INTO (ld_street, ld_city1, ld_str_suppl3, ld_country, ld_tlp, ld_fax)
  WHERE bukrs EQ wa_hd-bukrs.
endif.

SELECT SINGLE landx
  FROM t005t
  INTO ld_landx
  WHERE spras EQ sy-langu AND
        land1 EQ ld_country.

CONCATENATE ld_street ld_str_suppl3 ld_city1 ld_landx INTO va_alamat
  SEPARATED BY space.
CONCATENATE 'Telp :' ld_tlp 'Fax : ' ld_fax INTO va_telp
  SEPARATED BY space.





















