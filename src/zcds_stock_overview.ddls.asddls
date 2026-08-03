@AbapCatalog.sqlViewName: 'ZWMS_STOCK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock Overview'
define view zcds_stock as select
 from lqua
    left outer join makt 
    on lqua.matnr = makt.matnr 
    and makt.spras = 'E'
 left outer join marm
     on lqua.matnr = marm.matnr          
{
      key lgnum as warehouse,
      key    werks as plant,
      key   lgtyp as storage_type,
          lgpla as storage_bin,
          lqua.matnr as material_number,
          lqua.ausme as quantity_to_remove,
          makt.maktx as material_description,
          charg as batch,
          meins as uom,
          gesme  as quantity,
          cast(vfdat as abap.char(8)) as shelf_life_expiration, 
          cast(wdatu as abap.char(8)) as gr_date,
          bestq as special_stock,
          spras as language,
           marm.meinh as uom_carton,
           marm.umrez as conversion_carton,
           marm.umren
} where marm.meinh = 'KAR'
