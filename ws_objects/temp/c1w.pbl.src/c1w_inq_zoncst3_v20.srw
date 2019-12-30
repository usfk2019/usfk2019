$PBExportHeader$c1w_inq_zoncst3_v20.srw
$PBExportComments$[ohj] 홀세일 대역별 요율 조회 v20
forward
global type c1w_inq_zoncst3_v20 from w_a_inq_m
end type
type p_1 from u_p_saveas within c1w_inq_zoncst3_v20
end type
end forward

global type c1w_inq_zoncst3_v20 from w_a_inq_m
integer width = 4293
integer height = 1844
event ue_saveas ( )
p_1 p_1
end type
global c1w_inq_zoncst3_v20 c1w_inq_zoncst3_v20

type variables
boolean ib_sort_use
string is_method[], is_type[], is_svctype[]
end variables

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel! , True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

on c1w_inq_zoncst3_v20.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on c1w_inq_zoncst3_v20.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;//조회
String ls_parttype, ls_basis_date,ls_nodeno, ls_countrycod, ls_zoncod, ls_areacod, ls_svccod, ls_priceplan, ls_where, ls_priceplan_zone
Long ll_row
date ld_basis_date
datawindowchild ldc_zoncod, ldc_tmcod
ls_nodeno     = fs_snvl(dw_cond.object.nodeno[1]    , '')
//ls_countrycod = fs_snvl(dw_cond.object.countrycod[1], '')
ls_zoncod     = fs_snvl(dw_cond.object.zoncod[1]    , '')
ls_areacod    = fs_snvl(dw_cond.object.areacod[1]   , '')
ls_svccod     = fs_snvl(dw_cond.object.svccod[1]   , '')
ls_priceplan  = fs_snvl(dw_cond.object.priceplan[1], '')	 
ls_basis_date = string(dw_cond.object.basis_date[1], 'yyyymmdd')
ld_basis_date = dw_cond.object.basis_date[1]
ls_parttype   = fs_snvl(dw_cond.object.parttype[1], '')

//필수 항목 Check

If ls_parttype = "" Then
	f_msg_info(200, Title,"작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
	Return
End If	

If ls_parttype = 'S' Then
	ls_priceplan = 'ALL'		
	
	If ls_svccod = "" Then
		f_msg_info(200, Title,"서비스")
		dw_cond.SetFocus()
		dw_cond.SetColumn("svccod")
		Return
	End If
	
	dw_cond.object.priceplan[1] = ls_priceplan
Else
	
	If ls_priceplan = "" Then
		f_msg_info(200, Title,"가격정책")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
		Return
	End If
	
	SELECT SVCCOD
	  INTO :ls_svccod
	  FROM PRICEPLANMST
	 WHERE PRICEPLAN = :ls_priceplan;

	dw_cond.object.svccod[1]    = ls_svccod
	
End If

If ls_basis_date = "" Then
	f_msg_info(200, Title,"기준일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("basis_date")
	Return
End If

	
ll_row = dw_detail.GetChild("zoncod", ldc_zoncod)

If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ldc_zoncod.SetTransObject(SQLCA)

ls_priceplan_zone = dw_cond.object.priceplan[1]

IF ls_parttype = "S" THEN
	ll_row = ldc_zoncod.Retrieve(ls_svccod,'ALL','%')
ELSE
	ll_row = ldc_zoncod.Retrieve(ls_svccod,'ALL',ls_priceplan_zone)
END IF

IF ll_row < 1 Then 
	f_msg_usr_err(9000, Title, "대역코드가 존재하지 않습니다.")
	return
END IF
	

//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
ll_row = dw_detail.GetChild("tmcod", ldc_tmcod)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ldc_tmcod.SetTransObject(SQLCA)

IF ls_parttype = "S" THEN
	ll_row = ldc_tmcod.Retrieve(ls_svccod,'ALL','%')
	ELSE
	ll_row = ldc_tmcod.Retrieve(ls_svccod,'ALL',ls_priceplan_zone)
END IF

IF ll_row < 1 Then 
	f_msg_usr_err(9000, Title, "시간대코드가 존재하지 않습니다.")
	return
END IF

ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.SVCCOD = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.priceplan = '" + ls_priceplan + "' "
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.ZONCOD = '" + ls_zoncod + "' "
End If
If ls_nodeno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "b.nodeno = '" + ls_nodeno + "' "
End If

If ls_areacod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "b.AREACOD like '" + ls_areacod + "%' "
End If

If ls_basis_date <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.enddt is null and to_char(a.opendt, 'yyyymmdd') <= '" + ls_basis_date + "'"// and nvl(to_char(a.enddt, 'yyyymmdd'), '"+ls_basis_date+"') >= '"+ls_basis_date+"'"
End If

//retrieve
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//p_reload.TriggerEvent("ue_enable")	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_inq_zoncst3_v20
	Desc	:  홀세일용 서비스,가격정책 발신지별 대역 조회
	Ver	:	1.0
	Date	: 	2006.01.13
	Prgogramer : oh hye jin
--------------------------------------------------------------------------*/
Integer li_rc
String  ls_filter
DataWindowChild ldwc_nodeno, ldwc_svccod

dw_cond.Object.parttype[1] = "S"

dw_cond.Object.priceplan.Visible   = 0
dw_cond.Object.priceplan_t.Visible = 0
dw_cond.Object.svccod.Visible      = 1
dw_cond.Object.svccod_t.Visible    = 1		

//조회를 하고 나서 표준 대역 Load 할 수 있게 한다.
String ls_ref_desc, ls_temp

//홀세일정산:svctype(Inbound;outbound)  3;4
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("C1", "C231", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_svctype[])

li_rc = dw_cond.GetChild("svccod", ldwc_svccod)
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "GetChild : svccod")
	Return
End If

ls_filter = " svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
ldwc_svccod.SetFilter(ls_filter)
ldwc_svccod.Filter()

ldwc_svccod.SetTransObject(SQLCA)

li_rc = ldwc_svccod.Retrieve()
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "svccod Retrieve()")
	Return
End If	


end event

type dw_cond from w_a_inq_m`dw_cond within c1w_inq_zoncst3_v20
integer y = 44
integer width = 3447
integer height = 316
string dataobject = "c1dw_cnd_inq_zoncst3_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_filter, ls_svccod, ls_priceplan
Int li_rc

DataWindowChild ldwc_nodeno, ldwc_svccod, ldwc_priceplan

Choose Case dwo.Name
	Case "parttype"
		If data = "S" Then
			This.Object.priceplan.Visible = 0
			This.Object.priceplan_t.Visible = 0
			This.Object.svccod.Visible = 1
			This.Object.svccod_t.Visible = 1	
			dw_cond.SetItem(1, 'priceplan', 'ALL')
			dw_cond.SetItem(1, 'svccod'   , ''   )
			dw_cond.object.nodeno[1] = ''
			li_rc = dw_cond.GetChild("svccod", ldwc_svccod)
			If li_rc < 0 Then
				f_msg_usr_err(9000, Title, "GetChild : svccod")
				Return
			End If
			
			ls_filter = " svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
			ldwc_svccod.SetFilter(ls_filter)
			ldwc_svccod.Filter()
			
			ldwc_svccod.SetTransObject(SQLCA)
			
			li_rc = ldwc_svccod.Retrieve()
			If li_rc < 0 Then
				f_msg_usr_err(9000, Title, "svccod Retrieve()")
				Return
			End If			
		
		Else
			This.Object.priceplan.Visible = 1
			This.Object.priceplan_t.Visible = 1
			This.Object.svccod.Visible = 0
			This.Object.svccod_t.Visible = 0	
			dw_cond.SetItem(1, 'svccod'   , 'ALL')
			dw_cond.SetItem(1, 'priceplan', ''   )
			dw_cond.object.nodeno[1] = ''
			li_rc = dw_cond.GetChild("priceplan", ldwc_priceplan)
			If li_rc < 0 Then
				f_msg_usr_err(9000, Title, "GetChild : priceplan")
				Return
			End If
			
			ls_filter = " b.svctype in ('"+ is_svctype[1]+"','"+is_svctype[2]+"')"
			ldwc_priceplan.SetFilter(ls_filter)
			ldwc_priceplan.Filter()
			
			ldwc_priceplan.SetTransObject(SQLCA)
			
			li_rc = ldwc_priceplan.Retrieve()
			If li_rc < 0 Then
				f_msg_usr_err(9000, Title, "priceplan Retrieve()")
				Return
			End If				
		End If
		
	Case "svccod"
		// dddw change
//		dw_cond.Modify("nodeno.dddw.name = 'b0dc_dddw_nodeno_v20'")
//		dw_cond.Modify("nodeno.dddw.datacolumn = 'nodeno'")
//		dw_cond.Modify("nodeno.dddw.displayColumn = 'codenm'")
//		dw_cond.Modify("nodeno.dddw.UseAsBorder = 'Yes'")
//		dw_cond.Modify("nodeno.dddw.VScrollBar	= 'Yes'")				
	
		dw_cond.object.nodeno[1] = ''
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + data + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
	Case "priceplan"
		
		SELECT SVCCOD
	  	  INTO :ls_svccod
	     FROM PRICEPLANMST
	    WHERE PRICEPLAN = :data;
		
		dw_cond.object.nodeno[1] = ''
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
		
	Case "nodeno"
		If dw_cond.object.parttype[1] = "S" Then			
			
			ls_svccod = fs_snvl(dw_cond.Object.svccod[1], '')
			
			If ls_svccod = '' Then
				f_msg_info(9000, parent.title,  "서비스를 먼저 선택하여 주십시오.")
				This.Object.nodeno[1] = ""
				Return 2
			End If
			
		Else
			ls_priceplan = fs_snvl(dw_cond.Object.priceplan[1], '')
			
			If ls_priceplan = '' Then
				f_msg_info(9000, parent.title,  "가격정책을 먼저 선택하여 주십시오.")
				This.Object.nodeno[1] = ""
				Return 2
			End If
			
		End If
			

		
End Choose

end event

type p_ok from w_a_inq_m`p_ok within c1w_inq_zoncst3_v20
integer x = 3598
integer y = 92
end type

type p_close from w_a_inq_m`p_close within c1w_inq_zoncst3_v20
integer x = 3899
integer y = 92
end type

type gb_cond from w_a_inq_m`gb_cond within c1w_inq_zoncst3_v20
integer width = 3529
integer height = 368
end type

type dw_detail from w_a_inq_m`dw_detail within c1w_inq_zoncst3_v20
integer x = 32
integer y = 380
integer width = 4174
integer height = 1264
string dataobject = "c1dw_inq_zoncst3_v20"
boolean ib_sort_use = false
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_SORT = Object.zoncod_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_detail::constructor;call super::constructor;ib_sort_use = true
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return
If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

type p_1 from u_p_saveas within c1w_inq_zoncst3_v20
integer x = 3602
integer y = 200
boolean bringtotop = true
end type

