$PBExportHeader$u_d_sort.sru
$PBExportComments$dw Sort ( from u_d_base )
forward
global type u_d_sort from u_d_base
end type
end forward

global type u_d_sort from u_d_base
integer width = 1051
integer height = 360
event ue_init ( )
event type integer ue_after_sort ( )
end type
global u_d_sort u_d_sort

type variables
Public:
Boolean ib_sort_use = True  // sort 사용여부

Private :
// String is_current_sort_col  //현재 Sort된 col
// String is_old_sort_col  //전에 Sort된 col
 String is_unselect_text_color //선택않된 header text 색
 String is_select_text_color //선택된 header text 색

 DWObject idwo_old_header

 Constant String IS_RAISED = '6', IS_LOWERED = '5' , IS_RECTANGLE = '2'
 Constant String IS_ASC = 'A', IS_DESC = 'D'

 Constant String IS_ASC_OTHER = '오름차순', &
   IS_DESC_OTHER = '내림차순' //기존과 호완성을 위해 남겨둠

 String is_a_d
 Constant String IS_ASC_CHAR = 'A', &
   IS_DESC_CHAR = 'D'  //외부로 보여질 명명

Protected :
 Boolean ib_other = False  //기존과 호완성을 위해 남겨둠




end variables

forward prototypes
private function integer uf_sort_etc (ref dwobject adwo_click)
public function integer uf_init (dwobject adwo_sort_header, string as_asc_desc, long al_select_text_color)
public function integer uf_init_d (dwobject adwo_sort_header)
public function integer uf_init2 (dwobject adwo_sort_header)
public function integer uf_init (dwobject adwo_sort_header)
end prototypes

event ue_init;call super::ue_init;is_select_text_color = '0'
end event

private function integer uf_sort_etc (ref dwobject adwo_click);//목적 : 정렬 처리 및 정렬 처리와 관련된 사항 처리
//인자 : adwo_click - 클릭된 DWObject
//

String ls_setsort, ls_click_object

ls_click_object = adwo_click.Name

ls_setsort = LeftA(ls_click_object, LenA(ls_click_object) - 2)
If ls_setsort = "" Then Return -1

ls_setsort = ls_setsort + " " + is_a_d
SetSort(ls_setsort)
Sort()

Return 0
end function

public function integer uf_init (dwobject adwo_sort_header, string as_asc_desc, long al_select_text_color);//기능 :  초기화 작업
//인자 : adwo_sort_header : 처음 정렬할 칼럼
//       as_asc_desc : 오름/내림차순 ('A' = 오름차순, 'D' = 내림차순)
//       al_select_text_color : 정렬된 칼럼의 Header Text의 색
//

String ls_header_text, ls_setsort, ls_sort_col
Long ll_row_cnt

idwo_old_header = adwo_sort_header
is_select_text_color = String(al_select_text_color)
is_unselect_text_color = adwo_sort_header.Color

ls_header_text = adwo_sort_header.Text
ls_sort_col = LeftA(String(adwo_sort_header.Name), LenA(String(adwo_sort_header.Name)) - 2)

//화면 초기화
adwo_sort_header.Color = is_select_text_color

This.Object.order_name.Text = adwo_sort_header.Text

is_a_d = UPPER(as_asc_desc)

If Not ib_other Then
	If is_a_d <> IS_DESC Then
		This.Object.a_d.Text = IS_ASC_CHAR
	Else
		This.Object.a_d.Text = IS_DESC_CHAR
	End If
Else
	If is_a_d <> IS_DESC Then
		This.Object.a_d.Text = IS_ASC_OTHER
	Else
		This.Object.a_d.Text = IS_DESC_OTHER
	End If
End If

//정렬 초기화
ls_setsort = ls_sort_col + " " + is_a_d
This.SetSort(ls_setsort)
This.Sort()

Return 0

end function

public function integer uf_init_d (dwobject adwo_sort_header);//기능 :  초기화 작업
//인자 : adwo_sort_header : 처음 정렬할 칼럼

DWObject ldwo_col

ldwo_col = adwo_sort_header

Return uf_init(ldwo_col, 'D', RGB(255, 0, 0))

end function

public function integer uf_init2 (dwobject adwo_sort_header);//기능 :  초기화 작업
//인자 : adwo_sort_header : 처음 정렬할 칼럼

DWObject ldwo_col

ldwo_col = adwo_sort_header

Return uf_init(ldwo_col, 'D', RGB(255, 0, 0))

end function

public function integer uf_init (dwobject adwo_sort_header);//기능 :  초기화 작업
//인자 : adwo_sort_header : 처음 정렬할 칼럼

DWObject ldwo_col

ldwo_col = adwo_sort_header

Return uf_init(ldwo_col, 'A', RGB(0, 0, 128))

end function

event clicked;String ls_type, ls_header_name, ls_col_name, ls_setsort, ls_rc, ls_modify

If not ib_sort_use then return

If IsNull(dwo) Then Return
ls_type = dwo.Type


Choose Case UPPER(ls_type)
	Case "TEXT"
		ls_header_name = dwo.Name
		ls_col_name = LeftA(ls_header_name, LenA(ls_header_name) - 2)

		If RightA(ls_header_name, 2) = "_t" Then
			//화면변화
			dwo.Border = IS_LOWERED
			dwo.Color = is_select_text_color
			

			This.Object.order_name.Text = dwo.Text

			//오름차순, 내림차순 결정
			If dwo.Name = idwo_old_header.Name Then
//				If This.Object.a_d.Text <> IS_ASC Then
//					This.Object.a_d.Text = IS_ASC
//				Else
//					This.Object.a_d.Text = IS_DESC
//				End If

				If Not ib_other Then
					If is_a_d <> IS_ASC Then
						is_a_d = IS_ASC
						This.Object.a_d.Text = IS_ASC_CHAR
					Else
						is_a_d = IS_DESC
						This.Object.a_d.Text = IS_DESC_CHAR
					End If
				Else
					If is_a_d <> IS_ASC Then
						is_a_d = IS_ASC
						This.Object.a_d.Text = IS_ASC_OTHER
					Else
						is_a_d = IS_DESC
						This.Object.a_d.Text = IS_DESC_OTHER
					End If
				End If

//				If ib_other Then
//					If This.Object.a_d.Text <> IS_DESC Then
//						This.Object.a_d_other.Text = IS_ASC_OTHER
//					Else
//						This.Object.a_d_other.Text = IS_DESC_OTHER
//					End If
//				End If

			Else
				idwo_old_header.Color = is_unselect_text_color
				idwo_old_header = dwo
			End If

			uf_sort_etc(dwo)
			dwo.Border = IS_RECTANGLE

			//PB 6.0에서는 Sort()후에 선택된 열이 존재시 자동으로 첫번째 열이 선택되도록 한다.
			//그런데 화면상에서는 선택된 형태로 보이지 않는다. 그래서 아래의 함수를 사용..
//			SetRedraw(True) ==> sort후 선택된 열이 없는 상태되도록 하므로 필요가 없어짐.
			
			Trigger Event ue_after_sort()
		End If
	Case Else
End Choose

end event

event constructor;call super::constructor;Trigger Event ue_init()
end event

on u_d_sort.create
end on

on u_d_sort.destroy
end on

