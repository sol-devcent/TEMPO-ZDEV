IF wa_hd-nomon1 EQ space.
  va_nomon1 = wa_hd-nomon2.
ELSEIF wa_hd-nomon2 EQ space.
  va_nomon1 = wa_hd-nomon1.
ELSEIF wa_hd-nomon3 EQ space.
  CONCATENATE wa_hd-nomon1 ',' wa_hd-nomon2
  INTO va_nomon1
  SEPARATED BY space.
ELSEIF wa_hd-nomon4 EQ space.
  CONCATENATE wa_hd-nomon1 ',' wa_hd-nomon2 ',' wa_hd-nomon3
  INTO va_nomon1
  SEPARATED BY space.
ELSE.
  CONCATENATE wa_hd-nomon1 ',' wa_hd-nomon2 ',' wa_hd-nomon3 ','
              wa_hd-nomon4
  INTO va_nomon1
  SEPARATED BY space.
ENDIF.

IF wa_hd-nomon5 EQ space.
  va_nomon2 = wa_hd-nomon6.
ELSEIF wa_hd-nomon6 EQ space.
  va_nomon2 = wa_hd-nomon5.
ELSEIF wa_hd-nomon7 EQ space.
  CONCATENATE wa_hd-nomon5 ',' wa_hd-nomon6
  INTO va_nomon2
  SEPARATED BY space.
ELSEIF wa_hd-nomon8 EQ space.
  CONCATENATE wa_hd-nomon5 ',' wa_hd-nomon6 ',' wa_hd-nomon7
  INTO va_nomon2
  SEPARATED BY space.
ELSE.
  CONCATENATE wa_hd-nomon5 ',' wa_hd-nomon6 ',' wa_hd-nomon7 ','
              wa_hd-nomon8
  INTO va_nomon2
  SEPARATED BY space.
ENDIF.

IF wa_hd-nomon9 EQ space.
  va_nomon3 = wa_hd-nomon10.
ELSEIF wa_hd-nomon10 EQ space.
  va_nomon3 = wa_hd-nomon9.
ELSEIF wa_hd-nomon11 EQ space.
  CONCATENATE wa_hd-nomon9 ',' wa_hd-nomon10
  INTO va_nomon3
  SEPARATED BY space.
ELSEIF wa_hd-nomon12 EQ space.
  CONCATENATE wa_hd-nomon9 ',' wa_hd-nomon10 ',' wa_hd-nomon11
  INTO va_nomon3
  SEPARATED BY space.
ELSE.
  CONCATENATE wa_hd-nomon9 ',' wa_hd-nomon10 ',' wa_hd-nomon11 ','
              wa_hd-nomon12
  INTO va_nomon3
  SEPARATED BY space.
ENDIF.























