DATA: ld_peinh(6).
DATA: l_menge  TYPE char11.
DATA: l_kwert1 TYPE char15.

va_ebelp = wa_dt-ebelp.

*** Freight
WRITE wa_dt-freig TO va_kwert1 CURRENCY wa_hd-waers.
IF wa_hd-waers EQ 'IDR'.
va_waers = 'Rp'.
ELSE.
va_waers = wa_hd-waers.
ENDIF.

*WRITE wa_dt-kbetr TO va_kbetr NO-SIGN.
va_kbetr = wa_dt-kbetr.

*wa_dt-kbetr1 = wa_dt-kbetr1 / 10.
WRITE wa_dt-kbetr1 TO va_kbetr1 CURRENCY wa_hd-waers.
IF wa_hd-ld EQ space.
*---- Please don't change below this line ----*
WRITE wa_dt-hrgsat TO va_netpr CURRENCY 'USD'.
*---------------------------------------------*
ELSE.
IF wa_hd-waers = 'IDR'.
wa_dt-hrgsat = wa_dt-hrgsat / 100.
ENDIF.
WRITE wa_dt-hrgsat TO va_netpr CURRENCY wa_hd-waers.
break bcsha.
MOVE wa_dt-peinh TO ld_peinh.
IF ld_peinh <> 1.
SHIFT va_netpr LEFT BY 6 PLACES.
CONCATENATE '/' ld_peinh INTO ld_peinh.
CONCATENATE va_netpr ld_peinh INTO va_netpr SEPARATED BY space.
ENDIF.
ENDIF.
WRITE wa_dt-netwr  TO va_netwr CURRENCY wa_hd-waers.
WRITE wa_dt-disc1  TO va_disc1 CURRENCY wa_hd-waers NO-SIGN.
SHIFT va_disc1 LEFT DELETING LEADING space.
CONCATENATE '(' va_disc1 INTO va_disc1 SEPARATED BY space.

IF wa_dt-eindt EQ space.
va_eindt = space.
ELSE.
CONCATENATE wa_dt-eindt+6(2) wa_dt-eindt+4(2) wa_dt-eindt+2(2)
INTO va_eindt
SEPARATED BY '.'.
ENDIF.

*WRITE wa_dt-eindt TO va_eindt.

* Transport ????
*IF wa_dt-krech EQ 'C'.
*  wa_dt-kbetr2 = wa_dt-kbetr2 * 100.
*  va_kbetr2 = wa_dt-kbetr2 / wa_dt-kpein.
*ELSE.
WRITE wa_dt-kbetr2 TO va_kbetr2 CURRENCY wa_hd-waers.
*
*ENDIF.
WRITE wa_dt-surchg TO va_surchg CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr3 TO va_kbetr3 CURRENCY wa_hd-waers.
WRITE wa_dt-packchg TO va_packchg CURRENCY wa_hd-waers.

WRITE wa_dt-kbetr4 TO va_kbetr4 CURRENCY wa_hd-waers.
WRITE wa_dt-beabank TO va_beabank CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr5 TO va_kbetr5 CURRENCY wa_hd-waers.
WRITE wa_dt-handling TO va_handling CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr6 TO va_kbetr6 CURRENCY wa_hd-waers.
WRITE wa_dt-impduty TO va_impduty CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr7 TO va_kbetr7 CURRENCY wa_hd-waers.
WRITE wa_dt-insurance TO va_insurance CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr8 TO va_kbetr8 CURRENCY wa_hd-waers.
WRITE wa_dt-inlandtr TO va_inlandtr CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr9 TO va_kbetr9 CURRENCY wa_hd-waers.
WRITE wa_dt-trans TO va_trans CURRENCY wa_hd-waers.
WRITE wa_dt-kbetr10 TO va_kbetr10 CURRENCY wa_hd-waers.
WRITE wa_dt-matcost TO va_matcost CURRENCY wa_hd-waers.

IF wa_hd-kdatb NE '00000000'.
CONCATENATE va_eindt '( ETD )' INTO va_eindt
SEPARATED BY space.
ELSEIF wa_dt-charg NE space.
CONCATENATE va_eindt wa_dt-charg INTO va_eindt
SEPARATED BY space.
ENDIF.

IF wa_dt-ebelp NE 00000 AND
wa_dt-ebelp NE 99999 AND
wa_dt-ebelp NE 99998.
CONCATENATE wa_dt-ebeln wa_dt-ebelp INTO va_matpo.

IF wa_dt-ebeln IS INITIAL.
CLEAR: va_matpo.
va_matpo+10(5) = wa_dt-ebelp.
ENDIF.
ENDIF.

IF wa_hd-waers EQ 'IDR'.
*---- Please don't change below this line ----*
IF va_netpr+11(3) = ',00'.
SHIFT va_netpr RIGHT BY 4 PLACES.
ENDIF.
*---------------------------------------------*
va_netpr1 = 'Rp'.
va_netwr1 = 'Rp'.
ELSE.
va_netpr1 = wa_hd-waers.
va_netwr1 = wa_hd-waers.
ENDIF.

l_menge = wa_dt-menge.
l_menge = l_menge+7(3).

IF l_menge EQ 0.
va_flag = 0.
ELSE.
va_flag = 1.
ENDIF.

IF wa_dt-hrgsat IS INITIAL.
CLEAR va_netpr.
CLEAR va_netwr.
CLEAR va_netpr1.
CLEAR va_netwr1.
ENDIF.

IF wa_dt-ebelp EQ 00000.
ADD 1 TO va_count.
ENDIF.

IF wa_dt-ebelp EQ 99998.
IF va_count > 1.
CLEAR: va_count.
va_count1 = 1.
ENDIF.
ENDIF.







