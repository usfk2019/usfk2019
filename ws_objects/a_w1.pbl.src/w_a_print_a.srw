$PBExportHeader$w_a_print_a.srw
$PBExportComments$Print Ancestor(from w_base )
forward
global type w_a_print_a from w_base
end type
type dw_cond from u_d_external within w_a_print_a
end type
type p_ok from u_p_ok within w_a_print_a
end type
type p_close from u_p_close within w_a_print_a
end type
type dw_list from u_d_print within w_a_print_a
end type
type p_1 from u_p_psetup within w_a_print_a
end type
type p_2 from u_p_zoom within w_a_print_a
end type
type p_3 from u_p_print within w_a_print_a
end type
type p_5 from u_p_pfirst within w_a_print_a
end type
type p_6 from u_p_plast within w_a_print_a
end type
type p_7 from u_p_pnext within w_a_print_a
end type
type p_8 from u_p_pprev within w_a_print_a
end type
type p_9 from u_p_reset within w_a_print_a
end type
type p_4 from u_p_sort within w_a_print_a
end type
type gb_1 from groupbox within w_a_print_a
end type
type p_port from picture within w_a_print_a
end type
type p_land from picture within w_a_print_a
end type
type gb_cond from groupbox within w_a_print_a
end type
end forward

global type w_a_print_a from w_base
integer height = 1880
event ue_ok ( )
event ue_close ( )
event ue_set_header ( )
event ue_init ( )
event ue_pfirst ( )
event ue_sort ( )
event ue_preview_set ( )
event ue_plast ( )
event ue_pnext ( )
event ue_pprev ( )
event ue_print ( )
event ue_psetup ( )
event ue_reset ( )
event ue_zoom ( )
dw_cond dw_cond
p_ok p_ok
p_close p_close
dw_list dw_list
p_1 p_1
p_2 p_2
p_3 p_3
p_5 p_5
p_6 p_6
p_7 p_7
p_8 p_8
p_9 p_9
p_4 p_4
gb_1 gb_1
p_port p_port
p_land p_land
gb_cond gb_cond
end type
global w_a_print_a w_a_print_a

type variables
Datetime idt_now
u_cust_db_app iu_cust_db_app
String is_company_name, is_date_time, is_pgm_name 
String is_title
Boolean ib_header_set = True
Boolean ib_footer_set = True, ib_footer_line = True
boolean ib_print_horizental 
u_cust_a_msg iu_cust_msg1
String is_condition = ''
boolean ib_margin = True
integer ii_orientation = 0  
    // default from win95 , 1-Vertical, 2- Holizen, 
String is_pgm_id1 = ''

end variables

event ue_ok;call super::ue_ok;If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End if

end event

event ue_close;Close(This)
end event

event ue_set_header();If  ib_header_set Then 
	dw_list.setRedraw( False )
	
	dw_list.object.company_name.alignment = 0
	dw_list.object.company_name.width = len( is_company_name ) * 40
	dw_list.object.company_name.text = is_company_name
	
	IF	 is_pgm_id1 <> '' Then
		string ls_pgm_id
	End If		
	
//****kenn Modify 1998-12-04 Fri****
//**이유 : Title이 긴 출력물에서는 빈종이가 한장 더 출력 된다.
//**조치 : date_time과 title Text Object의 X, Width를 조정하지 못하게 한다.
//	dw_list.object.date_time.x = &
//		long( dw_list.object.date_time.x ) - &
//		( (len( is_date_time ) * 30  ) -Long( dw_list.object.date_time.width)  )
//	dw_list.object.date_time.width = len( is_date_time ) * 30
//****kenn****
	dw_list.object.date_time.alignment = 1
	dw_list.object.date_time.text = is_date_time
	
//	dw_list.object.title.x = &
//		long( dw_list.object.title.x ) - &
//		long( (  ( len( is_title ) * 60  ) - Long( dw_list.object.title.width)   ) / 2    )
//	dw_list.object.title.width = len( is_title ) * 60
	dw_list.object.title.alignment = 2
	dw_list.object.title.text = is_title
	
	If Not Isnull( is_condition ) Then
		If is_condition <> '' Then
			dw_list.object.condition.alignment = 2
//			dw_list.object.condition.x = &
//				long( dw_list.object.condition.x ) - &
//				Long( (len( is_condition ) * 30  ) -Long( dw_list.object.condition.width)/2  )
//			dw_list.object.condition.width = len( is_condition ) * 35
			dw_list.object.condition.text = is_condition
		End If			
	End If		

	dw_list.setRedraw( True )	
End If


Constant Integer lic_prt_height = 132
Integer	li_ori_height, li_title_width, li_title_x
String	ls_request, ls_describe, ls_modify
String	ls_ref_content, ls_ref_desc
String	ls_message

If Not ib_footer_set Then Return

ls_request = "p_logprt.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "p_logprt" Then Return

dw_list.SetRedraw(False)

ls_request = "datawindow.footer.height"
ls_describe = dw_list.Describe(ls_request)
li_ori_height = Integer(ls_describe)

//Title
ls_request = "title.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "title" Then
	ls_request = "title.X title.Width"
	ls_describe = dw_list.Describe(ls_request)
	li_title_x = Integer(Mid(ls_describe, 1, Pos(ls_describe, "~n") - 1))
	li_title_width = Integer(Mid(ls_describe, Pos(ls_describe, "~n") + 1))
Else
	li_title_x = 5
	li_title_width = 2745
End If

ls_modify = "datawindow.footer.height=" + String(li_ori_height + lic_prt_height)
dw_list.Modify(ls_modify)

ls_ref_content = fs_get_control("B0", "PRT1", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
ls_message = ls_ref_content
ls_ref_content = fs_get_control("B0", "PRT2", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
If ib_footer_line Then
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += "~r~n"
Else
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += " "
End If
//ls_message += ls_ref_content
//ls_modify = "create text(band=footer alignment=~"2~" text=~"" + ls_message + "~" border=~"0~" color=~"0~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height + 24) + "~" height=~"104~" width=~"" + String(li_title_width) + "~" name=t_logprt  font.face=~"굴림체~" font.height=~"-8~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"553648127~" )"
//dw_list.Modify(ls_modify)
//
//ls_modify = "create bitmap(band=footer filename=~"logprt.jpg~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height) + "~" height=~"128~" width=~"704~" border=~"0~" name=p_logprt )"
//dw_list.Modify(ls_modify)

dw_list.SetRedraw(True)

end event

event ue_init();
iu_cust_db_app = Create u_cust_db_app
////////////////////////////////////////////////////////////////////
//Get today & current time
iu_cust_db_app.is_caller = "NOW"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return

idt_now = iu_cust_db_app.idt_data[1]

is_date_time = String( Date( idt_now ), 'YYYY/MM/DD' ) + '  ' + String( Time( idt_now ) )

//////////////////////////////////////////////
// Get Company Name
iu_cust_db_app.is_caller = "GET_COMPANY_NAME"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then Return

is_company_name = iu_cust_db_app.is_data[1]
//////////////////////////////////////////////////
// Get Pgm title
is_title = is_pgm_name
/////////////////////////////////////////////


end event

event ue_pfirst;call super::ue_pfirst;dw_list.ScrollToRow(1)
dw_list.SetFocus()
end event

event ue_sort;call super::ue_sort;If dw_list.Rowcount() > 0 Then
	String ls_null
	SetNull( ls_null )
	dw_list.SetSort( ls_null )
	dw_list.Sort()
End If	
end event

event ue_preview_set;long ll_row

ll_row = dw_list.RowCount()

If ll_row >= 0 Then
	dw_list.Object.DataWindow.Print.Preview = 'Yes'

	If ib_margin then
		dw_list.object.datawindow.print.margin.Top = 0
	   dw_list.object.datawindow.print.margin.Bottom = 0
	   dw_list.object.datawindow.print.margin.Left = 0
	   dw_list.object.datawindow.print.margin.Right = 0
	End If

//	If p_land.invert Then  // vertical
//		dw_list.object.datawindow.print.orientation = 1
//	ElseIf p_port.invert then  // holizental
//		dw_list.object.datawindow.print.orientation = 2
//	Else	
		dw_list.object.datawindow.print.orientation = ii_orientation
		If ii_orientation = 1 Then
			p_land.invert = True
			p_port.invert = False
		ElseIf ii_orientation = 2 Then
			p_land.invert = False
			p_port.invert = True
		End If	
//	End If
End If


end event

event ue_plast;dw_list.ScrollToRow( dw_list.RowCount())

//한 Row가 3페이지 이상 걸쳐저서 존재하는 경우도 있기 때문에 일반적이지 않아 없애기로 함..
//dw_list.ScrollNextPage() //한 Row가 두페이지에 걸쳐서 있는 경우 때문...
dw_list.SetFocus()
end event

event ue_pnext;call super::ue_pnext;dw_list.ScrollNextPage()
dw_list.SetFocus()
end event

event ue_pprev;call super::ue_pprev;dw_list.ScrollPriorPage()
dw_list.SetFocus()
end event

event ue_print;string ls_page_cnt, ls_page
str_print_ref lstr_print_ref

If dw_list.RowCount() <= 0 then Return


dw_list.Object.DataWindow.Print.Page.Range = ""
TriggerEvent( "ue_preview_set" )
ls_page_cnt = dw_list.Describe("Evaluate('pagecount()',1)")

lstr_print_ref.s_page_cnt = ls_page_cnt
lstr_print_ref.i_ret = -1
OpenWithParm(w_print_page_setup, lstr_print_ref)
lstr_print_ref = Message.PowerObjectParm

If Not isnull( lstr_print_ref ) And lstr_print_ref.i_ret = 1 Then
	dw_list.object.datawindow.print.copies = String(lstr_print_ref.i_copies_n )
	dw_list.object.datawindow.print.page.range = lstr_print_ref.s_page_range

	If ib_margin Then
		dw_list.object.datawindow.print.margin.Top = 0
	   dw_list.object.datawindow.print.margin.Bottom = 0
	   dw_list.object.datawindow.print.margin.Left = 0
	   dw_list.object.datawindow.print.margin.Right = 0
	End If
	
	dw_list.print()
End If

end event

event ue_psetup;call super::ue_psetup;PrintSetup()
postEvent( "ue_preview_set" )
end event

event ue_reset;call super::ue_reset;
dw_list.Reset()
dw_cond.Reset()
dw_cond.InsertRow( 0 )
dw_cond.SetFocus()

end event

event ue_zoom;call super::ue_zoom;integer li_size
Open( w_zoom_size )
li_size = Message.DoubleParm

If li_size > 0 Then
	dw_list.object.datawindow.Zoom =   li_size 
End If	

end event

on w_a_print_a.create
int iCurrent
call super::create
this.dw_cond=create dw_cond
this.p_ok=create p_ok
this.p_close=create p_close
this.dw_list=create dw_list
this.p_1=create p_1
this.p_2=create p_2
this.p_3=create p_3
this.p_5=create p_5
this.p_6=create p_6
this.p_7=create p_7
this.p_8=create p_8
this.p_9=create p_9
this.p_4=create p_4
this.gb_1=create gb_1
this.p_port=create p_port
this.p_land=create p_land
this.gb_cond=create gb_cond
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_cond
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.dw_list
this.Control[iCurrent+5]=this.p_1
this.Control[iCurrent+6]=this.p_2
this.Control[iCurrent+7]=this.p_3
this.Control[iCurrent+8]=this.p_5
this.Control[iCurrent+9]=this.p_6
this.Control[iCurrent+10]=this.p_7
this.Control[iCurrent+11]=this.p_8
this.Control[iCurrent+12]=this.p_9
this.Control[iCurrent+13]=this.p_4
this.Control[iCurrent+14]=this.gb_1
this.Control[iCurrent+15]=this.p_port
this.Control[iCurrent+16]=this.p_land
this.Control[iCurrent+17]=this.gb_cond
end on

on w_a_print_a.destroy
call super::destroy
destroy(this.dw_cond)
destroy(this.p_ok)
destroy(this.p_close)
destroy(this.dw_list)
destroy(this.p_1)
destroy(this.p_2)
destroy(this.p_3)
destroy(this.p_5)
destroy(this.p_6)
destroy(this.p_7)
destroy(this.p_8)
destroy(this.p_9)
destroy(this.p_4)
destroy(this.gb_1)
destroy(this.p_port)
destroy(this.p_land)
destroy(this.gb_cond)
end on

event open;call super::open;//윈도우를 좌상단으로 이동
This.X = 1
This.Y = 1

is_pgm_id1 = iu_cust_msg.is_pgm_id

end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_list.Y + iu_cust_w_resize.ii_button_space) Then
	dw_list.Height = 0

	p_1.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_2.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_3.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_4.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_5.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_6.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_7.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_8.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
	p_9.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space

	gb_1.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space - iu_cust_w_resize.ii_gb_space
	p_port.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space - iu_cust_w_resize.ii_gb_space + iu_cust_w_resize.ii_port_space
	p_land.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space - iu_cust_w_resize.ii_gb_space + iu_cust_w_resize.ii_land_space
Else
	dw_list.Height = newheight - dw_list.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_1.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_2.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_3.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_4.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_5.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_6.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_7.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_8.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_9.Y	= newheight - iu_cust_w_resize.ii_button_space

	gb_1.Y	= newheight - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_gb_space
	p_port.Y	= newheight - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_gb_space + iu_cust_w_resize.ii_port_space
	p_land.Y	= newheight - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_gb_space + iu_cust_w_resize.ii_land_space
End If

If newwidth < dw_list.X  Then
	dw_list.Width = 0
Else
	dw_list.Width = newwidth - dw_list.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from u_d_external within w_a_print_a
event ue_key pbm_dwnkey
integer x = 59
integer y = 44
integer width = 2240
integer height = 268
integer taborder = 10
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_key;Choose Case key
	Case KeyEnter!
		Parent.TriggerEvent(is_default)
	Case KeyEscape!
		Parent.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

type p_ok from u_p_ok within w_a_print_a
integer x = 2441
integer y = 48
end type

type p_close from u_p_close within w_a_print_a
integer x = 2747
integer y = 48
boolean originalsize = false
end type

type dw_list from u_d_print within w_a_print_a
integer x = 37
integer y = 352
integer width = 3013
integer height = 1164
integer taborder = 20
borderstyle borderstyle = stylebox!
end type

event retrieveend;call super::retrieveend;Parent.Triggerevent('ue_preview_set')
Post Event ue_set_header()
end event

type p_1 from u_p_psetup within w_a_print_a
integer x = 2702
integer y = 1576
boolean originalsize = false
end type

type p_2 from u_p_zoom within w_a_print_a
integer x = 512
integer y = 1568
boolean originalsize = false
end type

type p_3 from u_p_print within w_a_print_a
integer x = 2400
integer y = 1576
boolean originalsize = false
end type

type p_5 from u_p_pfirst within w_a_print_a
integer x = 1253
integer y = 1572
boolean originalsize = false
end type

type p_6 from u_p_plast within w_a_print_a
integer x = 1847
integer y = 1572
boolean originalsize = false
end type

type p_7 from u_p_pnext within w_a_print_a
integer x = 1646
integer y = 1572
boolean originalsize = false
end type

type p_8 from u_p_pprev within w_a_print_a
integer x = 1449
integer y = 1572
boolean originalsize = false
end type

type p_9 from u_p_reset within w_a_print_a
integer x = 809
integer y = 1568
boolean originalsize = false
end type

type p_4 from u_p_sort within w_a_print_a
boolean visible = false
integer x = 992
integer y = 1660
integer width = 201
integer height = 168
end type

type gb_1 from groupbox within w_a_print_a
integer x = 50
integer y = 1540
integer width = 411
integer height = 192
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "Orientation"
borderstyle borderstyle = styleraised!
end type

type p_port from picture within w_a_print_a
event clicked pbm_bnclicked
integer x = 101
integer y = 1588
integer width = 123
integer height = 132
boolean bringtotop = true
string picturename = "port.bmp"
boolean focusrectangle = false
end type

event clicked;p_land.invert = false
invert = true

ii_orientation = 2
dw_list.object.datawindow.print.orientation = ii_orientation

dw_list.Object.DataWindow.Print.Preview = 'Yes'

//Parent.Triggerevent('ue_preview_set')
end event

type p_land from picture within w_a_print_a
event clicked pbm_bnclicked
integer x = 261
integer y = 1600
integer width = 151
integer height = 100
boolean bringtotop = true
string picturename = "land.bmp"
boolean focusrectangle = false
end type

event clicked;p_port.invert = false
invert = true

ii_orientation = 1
dw_list.object.datawindow.print.orientation = ii_orientation

dw_list.Object.DataWindow.Print.Preview = 'Yes'

//Parent.Triggerevent('ue_preview_set')
end event

type gb_cond from groupbox within w_a_print_a
integer x = 37
integer width = 2299
integer height = 332
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
end type

