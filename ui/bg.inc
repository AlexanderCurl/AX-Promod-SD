itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	visible			when( dvarString( fs_game ) == "" )
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front2"
	visible			when( dvarString( fs_game ) == "" )
	decoration
}


itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_back"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" )
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" )
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"animbg_front2"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != "" )
	decoration
}

itemDef

{

	name			"ticker_bg_color"

	style			1

	visible			when( !localvarBool( ui_hideBack ) )

	rect			-107 464 900 16

	backcolor		0.84 0.5 0.03 1

	decoration

}


itemDef

{

	name			"ticker_text"

	rect			475 464 0 0

	forecolor		1 1 1 1

	textaligny		14

	textscale		0.26

	textfont		8

	textstyle		ITEM_TEXTSTYLE_SHADOWEDMORE

	text			"[AX] Promod Servers  -  Mod by AlexC!  -  alexc.hu"

	visible			when( !localvarBool( ui_hideBack ) )

	exp rect x ( 854 - ( ( float( milliseconds( ) % 20000 ) / 20000 ) * ( 1054 ) ) )

}