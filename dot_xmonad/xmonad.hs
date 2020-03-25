--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
import qualified Data.Map as M
import Data.Maybe
import Data.Monoid
import Data.Tuple.Curry
import System.Exit
import System.Process (showCommandForUser)
import XMonad
import XMonad.Actions.CycleWS
import qualified XMonad.Actions.Search as S
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (ToggleStruts (ToggleStruts))
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Layout.AutoMaster
import XMonad.Layout.Column
import XMonad.Prompt
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.Scratchpad

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "myTerminal"

-- myTerminal      = "termite -e ~/.bin/tmux.sh"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod3Mask

myModMaskStr = "M3"

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#dddddd"

myFocusedBorderColor = "#ff0000"

----------------------------------------------------- -------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    [ ( (modm .|. controlMask, xK_Return),
        -- launch a terminal
        spawn $ XMonad.terminal conf
      ),
      ((modm, xK_Return), spawn $ XMonad.terminal conf),
      ((modm .|. shiftMask, xK_Return), spawn "urxvt"),
      -- launch dmenu
      ( (modm, xK_p),
        spawn
          "rofi -show combi -combi-modi window,drun,run -modi combi"
      ),
      ( (mod1Mask, xK_space),
        spawn
          "rofi -show combi -combi-modi window,drun,run -modi combi"
      ),
      ((mod4Mask .|. shiftMask, xK_k), spawn "keymap.sh"),
      -- launch gmrun
      ((modm .|. controlMask, xK_p), spawn "gmrun"),
      -- close focused window
      ((modm .|. shiftMask, xK_c), kill),
      ((modm .|. controlMask, xK_q), kill),
      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ( (modm .|. controlMask, xK_space),
        setLayout $ XMonad.layoutHook conf
      ),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Tab), windows W.focusDown),
      -- Move focus to the next window
      ((modm, xK_j), windows W.focusDown),
      -- Move focus to the previous window
      ((modm, xK_k), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm .|. controlMask, xK_m), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. controlMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. controlMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm, xK_h), sendMessage Shrink),
      -- Expand the master area
      ((modm, xK_l), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      ((modm, xK_b), sendMessage ToggleStruts),
      -- Quit xmonad
      ((modm .|. mod1Mask, xK_q), io (exitWith ExitSuccess)),
      -- Restart xmonad
      ((modm .|. controlMask, xK_r), spawn "xmonad --recompile; xmonad --restart"),
      ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
      -- Run xmessage with a summary of the default keybindings (useful for beginners)
      -- , ((modm .|. controlMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
      ++ [ ((m .|. modm, k), windows $ f i) --
               -- mod-[1..9], Switch to workspace N
               -- mod-shift-[1..9], Move client to workspace N
               --
           | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
             (f, m) <- [(W.greedyView, 0), (W.shift, controlMask)]
         ]
      ++ [ ( (m .|. modm, key),
             --
             -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
             -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
             --
             screenWorkspace sc >>= flip whenJust (windows . f)
           )
           | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..],
             (f, m) <- [(W.view, 0), (W.shift, controlMask)]
         ]

-- toggleOrView for people who prefer view to greedyView
toggleOrView' = toggleOrDoSkip [] W.view

-- toggleOrView ignoring scratchpad and named scratchpad workspace
toggleOrViewNoSP = toggleOrDoSkip ["NSP"] W.greedyView

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    [ ( (modm, button1),
        -- mod-button1, Set the window to floating mode and move by dragging
        ( \w ->
            focus w
              >> mouseMoveWindow w
              >> windows W.shiftMaster
        )
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), (\w -> focus w >> windows W.shiftMaster)),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        ( \w ->
            focus w
              >> mouseResizeWindow w
              >> windows W.shiftMaster
        )
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myPromptKeymap =
  M.union defaultXPKeymap $
    M.fromList
      [ ((controlMask, xK_g), quit),
        ((controlMask, xK_m), setSuccess True >> setDone True),
        ((controlMask, xK_j), setSuccess True >> setDone True),
        ((controlMask, xK_h), deleteString Prev),
        ((controlMask, xK_f), moveCursor Next),
        ((controlMask, xK_b), moveCursor Prev),
        ((controlMask, xK_p), moveHistory W.focusDown'),
        ((controlMask, xK_n), moveHistory W.focusUp'),
        ((mod1Mask, xK_p), moveHistory W.focusDown'),
        ((mod1Mask, xK_n), moveHistory W.focusUp'),
        ((mod1Mask, xK_b), moveWord Prev),
        ((mod1Mask, xK_f), moveWord Next)
      ]

myXPConfig =
  def
    { font = "xft:DejaVu Sans Mono:pixelsize=16",
      bgColor = "#0c1021",
      fgColor = "#f8f8f8",
      fgHLight = "#f8f8f8",
      bgHLight = "steelblue3",
      borderColor = "DarkOrange",
      promptBorderWidth = 1,
      position = Top,
      historyFilter = deleteConsecutive,
      promptKeymap = myPromptKeymap
    }

myAddtionalKeys =
  let searchEngineList =
        [ ("a archive", "https://web.archive.org/web/*/"),
          ("b goodreads", "https://www.goodreads.com/search?query="),
          ("d ddg duckduckgo", "https://duckduckgo.com/?q="),
          ("e devdocs", "https://devdocs.io/#q="),
          ("f stackoverflow", "https://stackoverflow.com/search?q="),
          ("g google", "http://www.google.com/search?num=100&q="),
          ("h haskell", "http://www.haskell.org/hoogle/?q="),
          ("i gh github", "https://github.com/search?type=Everything&repo=&langOverride=&start_value=1&q="),
          ("m msc mathscinet", "https://www.ams.org/mathscinet/search/publications.html?pg4=ALLF&s4="),
          ("r mref", "https://mathscinet.ams.org/mathscinet-mref?ref="),
          ("s scihub", "https://sci-hub.tw/"),
          ("w wikiwand", "https://www.wikiwand.com/en/"),
          ("dict", "http://www.dict.cc/?s="),
          ("imdb", "http://www.imdb.com/find?s=all&q="),
          ("def", "http://www.google.com/search?q=define:"),
          ("img", "http://images.google.com/images?q="),
          ("bb", "https://bitbucket.org/repo/all?name="),
          ("alpha", "http://www.wolframalpha.com/input/i="),
          ("ud", "http://www.urbandictionary.com/define.php?term="),
          ("rtd", "http://readthedocs.org/search/project/?q="),
          ("null", "http://nullege.com/codes/search/"),
          ("sf", "http://sourceforge.net/search/?q="),
          ("acm", "https://dl.acm.org/results.cfm?query="),
          ("math", "http://mathworld.wolfram.com/search/?query="),
          ("alexa", "https://www.alexa.com/siteinfo/"),
          ("alluc", "https://www.alluc.ee/stream/"),
          ("amazon", "https://www.amazon.com/s?field-keywordss="),
          ("amo", "https://addons.mozilla.org/-/firefox/search?cat=all&q="),
          ("archive_is", "https://archive.is/"),
          ("archlinux pac", "https://www.archlinux.org/packages/?q="),
          ("archwiki aw", "https://wiki.archlinux.org/index.php/Special:Search?fulltext=Search&search="),
          ("arxiv", "https://arxiv.org/find/all/1/all:+"),
          ("aur", "https://aur.archlinux.org/packages.php?O=0&&do_Search=go&K="),
          ("bing", "https://www.bing.com/search?q="),
          ("britannica", "https://www.britannica.com/search?query="),
          ("chocolatey", "https://chocolatey.org/packages?q="),
          ("cnrtl", "https://www.cnrtl.fr/lexicographie/"),
          ("cpp", "https://en.cppreference.com/mwiki/index.php?search="),
          ("devdocs", "https://devdocs.io/#q="),
          ("ddlw", "https://ddl-warez.in/?search="),
          ("doi", "https://doi.org/"),
          ("duden", "https://www.duden.de/suchen/dudenonline/"),
          ("ecosia", "https://ecosia.org/search.php?q="),
          ("emacswiki ew", "https://duckduckgo.com/?q=site%3Aemacswiki.org+"),
          ("gnome_developer", "http://developer.gnome.org/search?q="),
          ("googlebooks", "https://www.google.com/search?tbm=bks&q="),
          ("google_images", "https://www.google.com/images?hl=en&source=hp&biw=1440&bih=795&gbv=2&aq=f&aqi=&aql=&oq=&q="),
          ("google_maps", "https://www.google.com/maps/search/"),
          ("google_play", "https://play.google.com/store/search?c=apps&q="),
          ("google_scholar", "https://scholar.google.com/scholar?q="),
          ("google_translate", "https://translate.google.com/#auto|en|"),
          ("google_video", "https://www.google.com/search?q=TEST&tbm=vid"),
          ("greasyfork", "https://greasyfork.org/scripts?q=test"),
          ("mozilla_developer", "https://developer.mozilla.org/en-US/search?q="),
          ("ruby_doc", "http://www.ruby-doc.org/search.html?sa=Search&q="),
          ("ixquick", "https://ixquick.com/do/search?q="),
          ("gutenberg", "https://www.gutenberg.org/ebooks/search/?query="),
          ("larousse_fr_en", "https://www.larousse.fr/dictionnaires/francais-anglais/"),
          ("larousse", "https://www.larousse.fr/dictionnaires/francais/"),
          ("leo", "https://dict.leo.org/dictQuery/m-vocab/ende/de.html?searchLoc=0&lp=ende&lang=de&directN=0&search="),
          ("libgen library_genesis l", "http://gen.lib.rus.ec/search.php?res=100&req="),
          ("librivox", "https://librivox.org/search?search_form=advanced&q="),
          ("manual", "https://manned.org/browse/search?q="),
          ("manuals", "https://www.die.net/search/?sa=Search&ie=ISO-8859-1&cx=partner-pub-5823754184406795%3A54htp1rtx5u&cof=FORID%3A9&siteurl=www.die.net%2Fsearch%2F%3Fq%3DTEST%26sa%3DSearch#908&q="),
          ("manpages man", "https://manpages.ubuntu.com/cgi-bin/search.py?q="),
          ("mathoverflow mof", "https://mathoverflow.net/search?q="),
          ("merriam_webster mw", "https://www.merriam-webster.com/dictionary/"),
          ("merriam_webster_thesaurus mwt", "https://www.merriam-webster.com/thesaurus/"),
          ("metager", "https://metager.de/en/meta/meta.ger3?eingabe="),
          ("mnemonic_dictionary md", "https://www.mnemonicdictionary.com/word/"),
          ("ncbi", "https://www.ncbi.nlm.nih.gov/gquery/?term="),
          ("openlibrary ol", "https://www.openlibrary.org/search?q="),
          ("openstreetmap", "https://nominatim.openstreetmap.org/search.php?q="),
          ("opensubtitles os", "https://www.opensubtitles.org/en/search2/moviename-"),
          ("oxford", "https://en.oxforddictionaries.com/definition/"),
          ("php", "https://php.net/manual-lookup.php?scope=quickref&pattern="),
          ("python", "https://docs.python.org/3/search.html?q="),
          ("python2", "https://docs.python.org/2/search.html?q="),
          ("pypi", "https://pypi.python.org/pypi?:action=search&term="),
          ("qwant", "https://www.qwant.com/?client=opensearch&q="),
          ("reddit", "https://www.reddit.com/search?q="),
          ("science_willpowell_co", "https://science.willpowell.co.uk/?q="),
          ("slickdeals", "https://slickdeals.net/newsearch.php?q="),
          ("smzdm", "https://search.smzdm.com/?s="),
          ("snopes", "https://www.snopes.com/?s="),
          ("souyun", "https://sou-yun.com/QueryPoem.aspx?key="),
          ("springerlink", "https://link.springer.com/search?query="),
          ("startpage", "https://startpage.com/do/metasearch.pl?query="),
          ("opensuse suse", "https://en.opensuse.org/index.php?search="),
          ("twitter", "https://twitter.com/search?q="),
          ("vimeo", "https://vimeo.com/search?q="),
          ("vim", "https://vim.wikia.com/wiki/Special:Search?search="),
          ("wikileaks", "https://search.wikileaks.org/?q="),
          ("wikipedia_de", "https://de.wikipedia.org/wiki/Special:Search?search="),
          ("wikipedia_en", "https://en.wikipedia.org/wiki/Special:Search?search="),
          ("wikipedia_fr", "https://fr.wikipedia.org/wiki/Special:Search?search="),
          ("wikipedia", "https://www.wikipedia.org/search-redirect.php?language=en&go=Go&search="),
          ("wikipedia_zh", "https://zh.wikipedia.org/wiki/Special:Search?search="),
          ("wolframalpha alpha wa", "https://www.wolframalpha.com/input/?i="),
          ("wordpress_plugins", "https://wordpress.org/extend/plugins/search.php?q="),
          ("yahoo", "https://search.yahoo.com/search?p="),
          ("yandex", "https://www.yandex.com/search/?text="),
          ("youdao", "https://dict.youdao.com/search?q="),
          ("youtube", "https://www.youtube.com/results?aq=f&oq=&search_query="),
          ("zdic", "http://www.zdic.net/search/?q=")
        ]
      searchEngines = concatMap (\(name, url) -> map (\n -> S.searchEngine n url) (words name)) searchEngineList
      defaultSearchEngine = S.searchEngine "google" "http://www.google.com/search?num=100&q="
      searchEnginesCombined = S.namedEngine "multi" $ foldr1 (S.!>) searchEngines
      myMod x = myModMaskStr ++ "-" ++ x
      searchBindings =
        [ (myMod "C-/", S.promptSearch myXPConfig searchEnginesCombined),
          (unwords $ replicate 2 $ myMod "/", S.promptSearch myXPConfig defaultSearchEngine)
        ]
          ++ [(unwords [myMod "/", name], S.promptSearch myXPConfig e) | e@(S.SearchEngine name _) <- searchEngines, length name == 1]
      launcherMode1 x = unwords [myMod "x", x]
      launcherMode2 x = unwords [myMod "o", x]
      alternativeMode x = unwords [myMod "a", x]
      orgCapture x = (alternativeMode x, spawn $ unwords ["orgCapture.sh", x])
      powerMode key action = map (\k -> (unwords [myMod k, key], action)) ["<Delete>", "Pause", "XF86PowerOff"]
      myScratchpadSpawnAction = scratchpadSpawnAction defaults
   in searchBindings
        ++ [ ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10"),
             ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10"),
             ("<XF86AudioNext>", spawn "cmus-remote -n"),
             ("<XF86AudioPrev>", spawn "cmus-remote -r"),
             ("<XF86AudioRaiseVolume>", spawn "pamixer --increase 5"),
             ("<XF86AudioLowerVolume>", spawn "pamixer --decrease 5"),
             ("<XF86AudioMute>", spawn "pamixer --toggle-mute"),
             ("<XF86AudioPlay>", spawn "cmus-remote -p"),
             ("<XF86AudioPause>", spawn "cmus-remote -u"),
             ("<XF86Display>", spawn "xset dpms force standby"),
             ("<XF86Eject>", spawn "eject")
           ]
        ++ [ (launcherMode1 "e", spawn "emacsclientmod"),
             (launcherMode1 "d", spawn "zeal"),
             (launcherMode1 "g", spawn "goldendict"),
             (launcherMode1 "b", spawn "firefox"),
             (launcherMode1 "r", spawn "koreader"),
             (launcherMode1 "f", spawn "doublecmd"),
             (launcherMode1 "z", spawn "zotero"),
             (launcherMode1 "i", spawn "idea-community"),
             (launcherMode1 "v", spawn "codium"),
             (launcherMode1 "p", spawn "zathura"),
             (launcherMode1 "k", spawn "keepassxc"),
             (launcherMode1 "l", spawn "calibre"),
             (launcherMode1 "w", spawn "wireshark"),
             (launcherMode1 "s", safeSpawn "emacsclient" ["-c", "-e", "(sunrise)"]),
             (launcherMode1 "m", safeSpawn "emacsclient" ["-c", "-e", "(mu4e)"]),
             (launcherMode1 "c", uncurryN safeSpawn $ myGetTerminalCommand Nothing Nothing ["mc"])
           ]
        ++ [ (launcherMode2 "e", safeSpawn "emacsclient" ["-c", "-e", "(elfeed)"]),
             (launcherMode2 "d", spawn "noDisturb.sh"),
             (launcherMode2 "a", spawn "randomArt.sh"),
             (launcherMode2 "b", spawn "chromium"),
             (launcherMode2 "k", spawn "keymap.sh"),
             (launcherMode2 "m", spawn "mpv"),
             (launcherMode2 "f", spawn "pcmanfm")
           ]
        ++ [ (alternativeMode "t", myScratchpadSpawnAction)
           ]
        ++ map orgCapture ["i", "c", "j", "s", "q"]
        ++ map (\x -> (alternativeMode $ take 1 x, namedScratchpadAction myScratchpads $ unwords [x, "fzf"])) ["downloads", "reading", "zotero"]
        ++ map (\x -> (alternativeMode $ take 1 x, namedScratchpadAction myScratchpads x)) ["goldendict", "nnn", "mutt", "htop", "pyradio"]
        ++ map (\(n, k) -> (alternativeMode k, namedScratchpadAction myScratchpads n)) [("sdcv", "f"), ("calibre fzf", "l"), ("mpsyt", "y"), ("cmus", "u"), ("terminal", "a")]
        ++ powerMode "l" (spawn "xautolock -locknow")
        ++ powerMode "s" (spawn "systemctl suspend")
        ++ powerMode "h" (spawn "systemctl hibernate")
        ++ powerMode "r" (spawn "power.sh reboot")
        ++ powerMode "p" (spawn "power.sh poweroff")

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = tiled ||| Mirror tiled ||| Full ||| Column 1.6
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

myGetTerminalCommand :: Maybe String -> Maybe String -> [String] -> (String, [String])
myGetTerminalCommand title cls command = ("alacritty", (maybe [] (\x -> ["--title", x]) title) ++ (maybe [] (\x -> ["--class", x]) cls) ++ (if null command then [] else ["-e"] ++ command))

myGetTerminalCommandString :: Maybe String -> Maybe String -> [String] -> String
myGetTerminalCommandString title cls command = uncurry showCommandForUser $ myGetTerminalCommand title cls command

myScratchpadTuples =
  [ ("stardict", "stardict", (className =? "Stardict"), centerFloating),
    ("goldendict", "goldendict", (className =? "GoldenDict"), centerFloating),
    ("notes", "gvim --role notes ~/notes.txt", (role =? "notes"), nonFloating),
    runTerminal "terminal" ["tmux"] Nothing,
    runTerminal "mutt" ["neomutt", "-F", "~/.mutt/unifiedrc"] Nothing,
    runTerminal "sdcv" ["sdcv"] Nothing,
    runTerminal "pyradio" ["pyradio"] Nothing,
    runTerminal "nnn" ["nnn"] Nothing,
    runTerminal "mpsyt" ["mpsyt"] Nothing,
    runTerminal "cmus" ["cmus"] Nothing,
    runTerminal "htop" ["htop"] Nothing
  ]
    ++ map runFzfLaunch ["downloads", "calibre", "reading", "zotero"]
  where
    role = stringProperty "WM_WINDOW_ROLE"
    centerFloating = (customFloating $ W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3))
    runTerminal name command windowTitle =
      let t = (fromMaybe (unwords ["scratchpad", name]) windowTitle)
       in (name, myGetTerminalCommandString (Just t) Nothing command, title =? t, centerFloating)
    runFzfLaunch name = runTerminal (unwords [name, "fzf"]) ["fo.sh", name] $ Just $ unwords ["scratchpad", name, "fzf"]

myScratchpads = map (uncurryN NS) myScratchpadTuples

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =
  composeAll
    . concat
    $ [ [title =? t --> doFloat | t <- myTitleFloats],
        [className =? c --> doFloat | c <- myClassFloats],
        [className =? c <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog") <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "confirmEx") <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "Dialog") <&&> (not <$> appName =? "Popup") --> doShift "3" | c <- myBrowserClasses],
        [className =? c <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog") <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "confirmEx") <&&> (not <$> stringProperty "WM_WINDOW_ROLE" =? "Dialog") <&&> (not <$> appName =? "Popup") --> doShift "9" | c <- myBrowserClasses2],
        -- [className =? "keepassxc" --> doShift "7"],
        [title =? t --> doIgnore | t <- myTitleIgnores],
        [className =? c --> doIgnore | c <- myClassIgnores],
        [namedScratchpadManageHook myScratchpads]
      ]
  where
    myTitleFloats = ["Transferring"] -- for the KDE "open link" popup from konsole
    myClassFloats = ["Pinentry", "Mplayer"] -- for gpg passphrase entry
    myClassIgnores = ["desktop_window"]
    myTitleIgnores = ["kdesktop"]
    myBrowserClasses = ["Firefox", "Palemoon", "Navigator", "Firefox Developer Edition"]
    myBrowserClasses2 = ["Chromium-browser"]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--

myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  return () -- workaround for checkKeymap!
    -- workaround to integrate Java Swing/GUI apps into XMonad layouts;
    -- otherwise they just float around.
    -- setWMName "LG3D"
    -- workaround to keep xmobar/dock visible after xmonad restart; otherwise
    -- the dock can be lost/hidden behind wallpaper.
    -- spawn "xdotool windowraise `xdotool search --all --name xmobar`"
    -- spawnOnce "dropbox start"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- main = xmonad defaults
myToggleStruts XConfig {XMonad.modMask = modm} = (modm, xK_b)

myStatusBar = "xmobar"

myPP =
  xmobarPP
    { ppTitle = myPPTitle
    }

myPPTitle = xmobarColor "#87AFAF" ""

myPPTitleSanitize title = wrap (wrap "<raw=" ":" $ show (length shortTitle)) "/>" $ shortTitle
  where
    shortTitle = shorten 40 title

-- The main function.
main = xmonad =<< statusBar myStatusBar myPP myToggleStruts defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults =
  def -- simple stuff
    { terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      -- key bindings
      keys = myKeys,
      mouseBindings = myMouseBindings,
      -- hooks, layouts
      layoutHook = myLayout,
      manageHook = myManageHook,
      handleEventHook = myEventHook,
      logHook = myLogHook,
      startupHook = myStartupHook
    }
    `additionalKeysP` myAddtionalKeys

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The default modifier key is 'alt'. Default keybindings:",
      "",
      "-- launching and killing programs",
      "mod-Shift-Enter  Launch xterminal",
      "mod-p            Launch dmenu",
      "mod-Shift-p      Launch gmrun",
      "mod-Shift-c      Close/kill the focused window",
      "mod-Space        Rotate through the available layout algorithms",
      "mod-Shift-Space  Reset the layouts on the current workSpace to default",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "",
      "-- modifying the window order",
      "mod-Return   Swap the focused window and the master window",
      "mod-Shift-j  Swap the focused window with the next window",
      "mod-Shift-k  Swap the focused window with the previous window",
      "",
      "-- resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- increase or decrease number of windows in the master area",
      "mod-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- quit, or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-[1..9]   Switch to workSpace N",
      "",
      "-- Workspaces & screens",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]
