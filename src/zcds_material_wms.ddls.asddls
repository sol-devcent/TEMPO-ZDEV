@AbapCatalog.sqlViewName: 'ZWMS_MATERIAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Material WMS'
define view zcds_material_wms 
  as select from mara
  left outer join mlgn  on mara.matnr = mlgn.matnr
  left outer join t320  on mlgn.lgnum = t320.lgnum
  left outer join marc  on  t320.werks = marc.werks
                        and mara.matnr = marc.matnr
  left outer join makt  on mara.matnr = makt.matnr 
                       and makt.spras = 'E'
  left outer join marm  on mara.matnr = marm.matnr       
  left outer join mean  on mara.matnr = mean.matnr
                       and marm.meinh = mean.meinh     
{
  key mara.matnr,
  key t320.werks,
  key marm.meinh,
  key mean.ean11,
      makt.maktx,
      mara.meins,
      marm.umrez,
      marm.umren,
      mara.xchpf,
      mean.hpean,
      mara.mtart,
      mlgn.lgnum,
      marc.mmsta as vmsta
}
