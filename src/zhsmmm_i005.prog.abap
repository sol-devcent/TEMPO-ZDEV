*&---------------------------------------------------------------------*
*& Report  ZRVTPSC00                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&   Versendung einer Lieferung an eine Spediteur zwecks Frachtplanung *
*&---------------------------------------------------------------------*

REPORT  zhsmmm_i005 MESSAGE-ID v6.

TABLES: mara, pgmi, adrc, lfa1, t052, tcurt, a049, eipa, ekko, ekpo, konp.

SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS s_werks       FOR pgmi-werks NO-DISPLAY.
SELECT-OPTIONS s_prgrp       FOR pgmi-prgrp." OBLIGATORY.
SELECT-OPTIONS s_matnr       FOR mara-matnr. " OBLIGATORY.
SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS s_lifnr       FOR lfa1-lifnr.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS s_zterm       FOR t052-zterm. " OBLIGATORY.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS s_waers       FOR tcurt-waers.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_rad4 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad1 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad2 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad3 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad5 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad6 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad7 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad8 RADIOBUTTON GROUP grp1.

START-OF-SELECTION.

  CASE 'X'.
    WHEN p_rad1.
      IF s_prgrp[] IS INITIAL AND s_matnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Masukkan kode material atau product group'.
      ELSE.
        PERFORM send_data_material.
      ENDIF.
    WHEN p_rad2.
      IF s_lifnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Masukkan kode Vendor'.
      ELSE.
        PERFORM send_data_vendor.
      ENDIF.
    WHEN p_rad3.
      PERFORM send_currency.
    WHEN p_rad4.
      IF s_prgrp[] IS INITIAL AND s_matnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Masukkan kode material atau product group'.
      ELSE.
        PERFORM send_data.
      ENDIF.
    WHEN p_rad5.
      IF s_zterm[] IS INITIAL AND s_matnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Massukan Payment Terms'.
      ELSE.
        PERFORM send_data_term.
      ENDIF.
    WHEN p_rad6.
      IF s_waers[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Massukan Currency'.
      ELSE.
        PERFORM send_data_curr.
      ENDIF.
    WHEN p_rad7.
      IF s_prgrp[] IS INITIAL AND s_matnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Masukkan kode material atau product group'.
      ELSE.
        PERFORM send_data_fpkh.
      ENDIF.
    WHEN p_rad8.
      IF s_matnr[] IS INITIAL.
        MESSAGE e000(zb) WITH 'Wajib memasukkan kode material '.
      ELSE.
        perform f_send_material_non_tender.
      ENDIF.

  ENDCASE.
  INCLUDE zhsmmm_i005f01.
*  INCLUDE zhsmmm_i003f01.
