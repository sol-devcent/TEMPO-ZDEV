SELECT SINGLE ktext
  FROM cskt
  INTO va_ktext
  WHERE spras EQ 'EN' AND
        kokrs EQ '8010' AND
        kostl EQ iloa-kostl.

SELECT SINGLE arbpl
  FROM crhd
  INTO va_arbpl
  WHERE objty EQ 'A' AND
        objid EQ iloa-ppsid.

SELECT SINGLE ktext
  FROM crtx
  INTO va_ktext1
  WHERE objid EQ iloa-ppsid.

























