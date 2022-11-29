---
-- /@ loss of control; // s0h2x, pretty_wow @/

local L, private = ...;
local GetLocale = GetLocale;
local locale = GetLocale();

if locale == "ruRU" then
	LOSS_OF_CONTROL_SECONDS = "сек.";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Перетащить/проскролить";
	MSG_CHAT_RESET = "Позиция сброшена по умолчанию.";
elseif locale == "esMX" or locale == "esES" then
	LOSS_OF_CONTROL_SECONDS = "segundos";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Arrastrar/Desplazar";
	MSG_CHAT_RESET = "Restablecimiento de la posición por defecto.";
elseif locale == "deDE" then
	LOSS_OF_CONTROL_SECONDS = "Sek.";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Ziehen/Scrollen";
	MSG_CHAT_RESET = "Position auf Standard zurückgesetzt.";
elseif locale == "frFR" then
	LOSS_OF_CONTROL_SECONDS = "secondes";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Glisser/Défiler";
	MSG_CHAT_RESET = "Position réinitialisée par défaut.";
elseif locale == "itIT" then
	LOSS_OF_CONTROL_SECONDS = "secondi";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Trascina/Scorri";
	MSG_CHAT_RESET = "Posizione ripristinata ai valori predefiniti.";
elseif locale == "koKR" then
	LOSS_OF_CONTROL_SECONDS = "초";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "드래그/스크롤";
	MSG_CHAT_RESET = "위치가 기본값으로 재설정됩니다.";
elseif locale == "ptBR" or locale == "ptPT" then
	LOSS_OF_CONTROL_SECONDS = "segundos";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Arrastar/Rolar";
	MSG_CHAT_RESET = "Posição redefinida para o padrão.";
elseif locale == "zhCN" or locale == "zhTW" then
	LOSS_OF_CONTROL_SECONDS = "秒";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "拖动/滚动";
	MSG_CHAT_RESET = "位置重置为默认值。";
else
	LOSS_OF_CONTROL_SECONDS = "seconds";
	DRAG_TO_MOVE_SCROLL_TO_SIZE = "Drag/Scroll";
	MSG_CHAT_RESET = "Position reset to default.";
end