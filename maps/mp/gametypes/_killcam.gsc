#include maps\mp\gametypes\_hud_util;

init ()
{
  precacheString (&"PLATFORM_PRESS_TO_SKIP");
  precacheString (&"PLATFORM_PRESS_TO_RESPAWN");
  precacheShader ("white");
  precacheShader ("hud_icon_ak47");
  level.killcam = maps\mp\gametypes\_tweakables::getTweakableValue ("game", "allowkillcam");
  
  if (level.killcam)
    setArchive (true);
}

killcam (attackerNum, killcamentity, sWeapon, predelay, offsetTime, respawn, maxtime, perks, attacker)
{
  self endon ("disconnect");
  self endon ("spawned");
  level endon ("game_ended");
  
  setDvar( "scr_gameended", 0 );
  self setClientDvar( "scr_gameended", getDvar( "scr_gameended" ) );
  
  if (attackerNum < 0)
    return;
    
  if (!respawn)
    camtime = 5;
  else if (sWeapon == "frag_grenade_mp" || sWeapon == "frag_grenade_short_mp")
    camtime = 4.5;
  else
    camtime = 2.5;
    
  if (isdefined (maxtime))
  {
    if (camtime > maxtime)
      camtime = maxtime;
      
    if (camtime < 0.05)
      amtime = 0.05;
  }
  
  postdelay = 2;
  killcamlength = camtime + postdelay;
  
  if (isdefined (maxtime) && killcamlength > maxtime)
  {
    if (maxtime < 2)
      return;
      
    if (maxtime - camtime >= 1)
      postdelay = maxtime - camtime;
    else
    {
      postdelay = 1;
      amtime = maxtime - 1;
    }
    
    killcamlength = camtime + postdelay;
  }
  
  killcamoffset = camtime + predelay;
  self notify ("begin_killcam", getTime ());
  self.sessionstate = "spectator";
  self.spectatorclient = attackerNum;
  self.killcamentity = killcamentity;
  self.archivetime = killcamoffset;
  self.killcamlength = killcamlength;
  self.psoffsettime = offsetTime;
  self allowSpectateTeam ("allies", true);
  self allowSpectateTeam ("axis", true);
  self allowSpectateTeam ("freelook", true);
  self allowSpectateTeam ("none", true);
  
  wait 0.05;
  
  if (self.archivetime <= predelay)
  {
    self.sessionstate = "dead";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    return;
  }
  
  self.killcam = true;
  
  if (!isdefined (self.kc_skiptext))
  {
    self.kc_skiptext = newClientHudElem (self);
    self.kc_skiptext.archived = false;
    self.kc_skiptext.x = 0;
    self.kc_skiptext.alignX = "center";
    self.kc_skiptext.alignY = "middle";
    self.kc_skiptext.horzAlign = "center_safearea";
    self.kc_skiptext.vertAlign = "top";
    self.kc_skiptext.sort = 1;
    self.kc_skiptext.font = "objective";
    self.kc_skiptext.foreground = true;
    self.kc_skiptext.y = 60;
    self.kc_skiptext.fontscale = 2;
  }
  
  if (respawn)
    self.kc_skiptext setText (&"PLATFORM_PRESS_TO_RESPAWN");
  else
    self.kc_skiptext setText (&"PLATFORM_PRESS_TO_SKIP");
  
  self.kc_skiptext.alpha = 1;
  
  if (!isdefined (self.kc_timer))
  {
    self.kc_timer = createFontString ("objective", 2);
    self.kc_timer setPoint ("BOTTOM", undefined, 0, -60);
    self.kc_timer.archived = false;
    self.kc_timer.foreground = true;
  }
  
  self.kc_timer.alpha = 1;
  self.kc_timer setTenthsTimer (camtime);
  
  self thread spawnedKillcamCleanup ();
  self thread endedKillcamCleanup ();
  self thread waitSkipKillcamButton ();
  self thread waitKillcamTime ();
  self waittill ("end_killcam");
  self endKillcam ();
  self.sessionstate = "dead";
  self.spectatorclient = -1;
  self.killcamentity = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
}

waitKillcamTime ()
{
  self endon ("disconnect");
  self endon ("end_killcam");
  
  wait (self.killcamlength - 0.05);
  
  self notify ("end_killcam");
}

waitSkipKillcamButton ()
{
  self endon ("disconnect");
  self endon ("end_killcam");
  
  while (self useButtonPressed ())
    wait 0.05;
    
  while (!(self useButtonPressed ()))
    wait 0.05;
    
  self notify ("end_killcam");
}

endKillcam ()
{
  if (isDefined (self.kc_skiptext))
    self.kc_skiptext.alpha = 0;
    
  if (isDefined (self.kc_timer))  
    self.kc_timer.alpha = 0;
    
  self.killcam = undefined;
  self thread maps\mp\gametypes\_spectating::setSpectatePermissions ();
}

spawnedKillcamCleanup ()
{
  self endon("end_killcam");
  self endon("disconnect");
  
  self waittill("spawned");
  
  self endKillcam();
}

spectatorKillcamCleanup (attacker)
{
  self endon("end_killcam");
  self endon("disconnect");
  attacker endon("disconnect");
  
  attacker waittill("begin_killcam", attackerKcStartTime);
  
  waitTime = max(0, (attackerKcStartTime - self.deathTime) - 50);
  wait waitTime;
  self endKillcam();
}

endedKillcamCleanup()
{
  self endon("end_killcam");
  self endon("disconnect");
  
  level waittill("game_ended");
  
  self endKillcam();
}


roundwinningkill( attackerNum, killcamentity, sWeapon, nothing, attacker )
{
  self endon("disconnect");
  
	if(!isDefined(level.bb_lastkill)||level.bb_lastkill[4]==false)
		return;
	if(level.bombExploded || level.bombDefused)
		return;
  
	self setclientdvar( "lastkillweapon", getWeaponImageName( sWeapon ) );
  
  setDvar( "scr_gameended", 2 );    
  self setClientDvar( "scr_gameended", getDvar( "scr_gameended" ) );
  self setclientdvar("last_killcam", 1);
  predelay = 3;// Time after the Kill
  camtime = 7;// Full Time for the Cam
  postdelay = 16;// Time bevore the kill
  killcamlength = 7;
  killcamoffset = camtime + predelay;
  self notify ( "begin_killcam", getTime() );
  
  self.villain = createFontString( "default", level.lowerTextFontSize );
  self.villain setPoint( "CENTER", "BOTTOM", -500, -110 ); 
  self.villain.alignX = "right";
  self.villain.archived = false;
  self.villain setText( attacker );
  self.villain.alpha = 1;
  self.villain.glowalpha = 1;
  self.villain.glowColor = getcolorvillain( self.pers["team"], attacker.pers["team"] );  
  self.villain MoveOverTime( 4 );
  self.villain.x = -20;  

  self.versus = createFontString( "default", level.lowerTextFontSize );
  self.versus.alpha = 0;
  self.versus setPoint( "CENTER", "BOTTOM", 0, -110 );  
  self.versus.archived = false;
  self.versus setText( "vs" );
  self.versus FadeOverTime( 4 );
  self.versus.alpha = 1;
  
  self.victim = createFontString( "default", level.lowerTextFontSize );
  self.victim setPoint( "CENTER", "BOTTOM", 500, -110 );
  self.victim.alignX = "left";  
  self.victim.archived = false;
  self.victim setText( level.victim ); 
  self.victim.glowalpha = 1; 
  self.victim.glowColor = getcolorvictim( self.pers["team"], level.victim.pers["team"] );
  self.victim MoveOverTime( 4 );
  self.victim.x = 20; 
  
  if ( isDefined( self.carryIcon ) )
    self.carryIcon destroy();
    
  self.sessionstate = "spectator";
  self.spectatorclient = attackerNum;
  self.killcamentity = killcamentity;
  self.archivetime = killcamoffset;
  self.killcamlength = killcamlength;
  self.psoffsettime = 3;
  self allowSpectateTeam("allies", true);
  self allowSpectateTeam("axis", true);
  self allowSpectateTeam("freelook", true);
  self allowSpectateTeam("none", true);
  
  wait 0.05;
  
  self.killcam = true;
  
  if ( !level.splitscreen )
  {
		if ( !isdefined( self.kc_timer ) )
		{
			self.kc_timer = createFontString( "default", 2.0 );
			self.kc_timer setPoint( "BOTTOM", undefined, 0, -17 );
			self.kc_timer.archived = false;
			self.kc_timer.foreground = true;
		}

    self.kc_timer.alpha = 1;
    self.kc_timer setTenthsTimer( camtime );
  }
  
  self thread waitKillcamTime();
  
  self waittill("end_killcam");
  
  self.villain destroy();
  self.versus destroy();
  self.victim destroy();
  
  self endKillcam();
  self.sessionstate = "dead";
  self.spectatorclient = -1;
  self.killcamentity = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
}

getWeaponImageName( weapon )
{  
  weaponname = StrTok( weapon, "_" );  

  if ( weapon == "m1014_mp" )
  {    
    weapon = "hud_icon_benelli_m4";
  }
  else if ( weapon == "beretta_mp" )
  {   
    weapon = "hud_icon_m9" + weaponname[0];
  }
  else if ( weapon == "flash_grenade_mp" ||  weapon == "smoke_grenade_mp" ||  weapon == "frag_grenade_mp" )
  {
    if ( weaponname[0] == "frag" )
      weaponname[0] = "";
    
    weapon = "hud_us_" + weaponname[0] + "grenade";
  }
  else if ( weapon == "deserteagle_mp" ||  weapon == "deserteaglegold_mp" ||  weapon == "remington700_mp" || weapon == "winchester1200_mp")
  {
    if ( weaponname[0] == "remington700" )
      weapon = "hud_icon_remington_700";
    else if ( weaponname[0] == "winchester1200" )
      weapon = "hud_icon_winchester_1200";
    else
      weapon = "hud_icon_desert_eagle";
  }
  else if ( weapon == "m4_mp" ||  weapon == "m16_mp" ||  weapon == "usp_mp" )
  {
    if ( weaponname[0] == "m4" )
      weap = "carbine";
    else if ( weaponname[0] == "m16" )
      weap = "a4";
    else
      weap = "_45";
    
    weapon = "hud_icon_" + weaponname[0] + weap;
  }
  else if ( weapon == "uzi_mp" )    
  {
    weapon = "hud_icon_mini_" + weaponname[0];
  }
  else
  {
    weapon = "hud_icon_" + weaponname[0]; 
  }
  
  return weapon;
}

getcolorvillain( myteam, villainteam )
{
  if ( myteam == "allies" )
  {
    if ( myteam == villainteam )
      colorvillain = ( 0.26, 0.62, 0.99 );
    else
      colorvillain = ( 0.93, 0.28, 0.28 );
  }
  else
  {
    if ( myteam == villainteam )
      colorvillain = ( 0.93, 0.28, 0.28 );
    else
      colorvillain = ( 0.26, 0.62, 0.99 );
  }
  
  return colorvillain;
}

getcolorvictim( myteam, victimteam )
{
  if ( myteam == "allies" )
  {
    if ( myteam == victimteam )
      colorvictim = ( 0.26, 0.62, 0.99 );
    else
      colorvictim = ( 0.93, 0.28, 0.28 );
  }
  else
  {
    if ( myteam == victimteam )
      colorvictim = ( 0.93, 0.28, 0.28 );
    else
      colorvictim = ( 0.26, 0.62, 0.99 );
  }
  
  return colorvictim;
}

reachedRoundLimit()
{
  if ( game["roundsplayed"] == level.roundLimit )
    return true;
  else
    return false;
}