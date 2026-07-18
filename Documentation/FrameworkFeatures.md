# Framework Features

MyFbFramework is more than the toolbox. These are the parts you cannot drag onto a form but
will want when writing the code behind one - files, settings, the registry, HTTP, drawing,
collections and string handling.

For the controls themselves see [Controls.md](Controls.md).

**Where this comes from.** Descriptions are taken from the MyFbFramework help file where it
covers a type, and written from the headers in `Controls/Framework/mff/` where it does not
(`Registry`, `Console`, `HTTP`, `Graphics`, `SysUtils`). Warnings come from this project's own
experience with the framework.

**Using any of these** means including its header, for example:

```freebasic
#include once "mff/IniFile.bi"
```

The `mff/` prefix resolves to `Controls/Framework/mff/`, which the IDE puts on the include path
for every build.

**Platform.** Astoria targets Windows, so upstream's cross-platform annotations have been
stripped - everything listed here is available to you. The MyFbFramework help shows notes like
*(Windows, Linux)*; those describe the framework's reach, not Astoria's.

---

## System and OS

### Clipboard

Provides methods to place data on and retrieve data from the system Clipboard.

Read and write the system clipboard.

`#include once "mff/Clipboard.bi"`

### Registry

Reads and writes Windows registry values. `ReadRegistry(Group, Section, Key)` returns a String; `WriteRegistry(Group, Section, Key, ValType, Value)` sets one, with `Group` being an `HKEY` such as `HKEY_CURRENT_USER`.

`#include once "mff/Registry.bi"`

> [!WARNING]
> Writing to the registry affects the whole machine or user profile, and a bad value can break other software. Prefer `IniFile` for ordinary application settings.

### IniFile

Class for working with ini files.

The usual choice for application settings - a plain `.ini` file you can read, ship and diff.

`#include once "mff/IniFile.bi"`

### SystemInformation

Query screen metrics, OS version and similar environment details.

`#include once "mff/SystemInformation.bi"`

### Console

Controls a Windows console window from a program that has one: colours, cursor position, buffer and window size, and the console font.

`#include once "mff/Console.bi"`

> [!WARNING]
> Only meaningful in a console subsystem program. A GUI program has no console attached unless it allocates one.

### Sys / SysUtils

General-purpose helpers used throughout the framework - path and file manipulation, string utilities and conversions. `SysUtils` is the one most application code reaches for.

`#include once "mff/SysUtils.bi"`

---

## Networking

### HTTP

Sends HTTP requests and receives responses from a URI. Build an `HTTPRequest`, call `CallMethod("GET", request, response)`, and read the `HTTPResponce`. Supports cancelling an in-flight request via the `Abort` property, and setting a User-Agent.

`#include once "mff/HTTP.bi"`

> [!WARNING]
> Note the spelling: the response type is `HTTPResponce`, not `HTTPResponse`.

> [!WARNING]
> The `HTTPConnection` component in the toolbox is the designer-friendly wrapper over this; use that if you want it on a form.

---

## Drawing

### Canvas

Canvas is a class that allows you to create and draw graphics.

The drawing surface. Most controls expose one as `.Canvas`, and that is where custom painting happens.

`#include once "mff/Canvas.bi"`

### Graphics

Colour helpers rather than a drawing surface: conversions between RGB, BGR and ARGB (`ColorToRGB`, `RGBAToBGR`, `RGBtoARGB`), channel extraction (`GetRed`, `GetGreen`, `GetBlue`), blending (`ShiftColor`) and `IsDarkColor`.

`#include once "mff/Graphics.bi"`

> [!WARNING]
> `IsDarkColor` is the basis of the framework's dark-mode handling - useful if you are theming custom-drawn controls.

### Brush

Defines objects used to fill the interiors of graphical shapes such as rectangles, ellipses, pies, polygons, and paths.

Fill style for shapes and backgrounds.

`#include once "mff/Brush.bi"`

### Pen

Defines an object used to draw lines and curves.

Line style for outlines and strokes.

`#include once "mff/Pen.bi"`

### Font

MyFbFramework. `Font` - Defines text formatting attributes including typeface, size, and style characteristics.

A font, as assigned to a control's `.Font`.

`#include once "mff/Font.bi"`

### Icon

Represents a icon, which is a small bitmap image that is used to represent an object.

An icon resource, for windows, tray icons and buttons.

`#include once "mff/Icon.bi"`

### BitmapType

Is an object used to work with images defined by pixel data.

A bitmap image, used by ImageBox, ImageList and custom painting.

`#include once "mff/Bitmap.bi"`

---

## Collections

### List

Represents a list of objects that can be accessed by index. Provides methods to search, sort, and manipulate lists.

The framework's general-purpose list, used widely by the controls themselves.

`#include once "mff/List.bi"`

### Dictionary

Represents a collection of keys and values.

Key/value lookup.

`#include once "mff/Dictionary.bi"`

### StringList

Represents a list of strings that can be accessed by index. Provides methods to search, sort, and manipulate lists.

A list of `String` values.

`#include once "mff/StringList.bi"`

### WStringList

Represents a list of wstrings that can be accessed by index. Provides methods to search, sort, and manipulate lists.

A list of `WString` (wide/Unicode) values - the right choice when text may be non-ASCII.

`#include once "mff/WStringList.bi"`

### IntegerList

Represents a list of integers that can be accessed by index. Provides methods to search, sort, and manipulate lists.

A list of integers.

`#include once "mff/IntegerList.bi"`

### DoubleList

Represents a list of doubles that can be accessed by index. Provides methods to search, sort, and manipulate lists.

A list of doubles.

`#include once "mff/DoubleList.bi"`

### PointerList

Represents a list of pointers that can be accessed by index. Provides methods to search, sort, and manipulate lists.

A list of raw pointers.

`#include once "mff/PointerList.bi"`

> [!WARNING]
> Stores pointers only - it does not own or free what they point at.

---

## Core

### Application

Provides methods and properties to manage an application, such as methods to start and stop an application, and properties to get information about an application..

The running application object - `App`. Carries the message loop (`App.Run`), the executable path, and the current language settings.

`#include once "mff/Application.bi"`

### UString

The framework's Unicode string type, extending `WString`. Used throughout Astoria and MFF in preference to `String` wherever text may be non-ASCII.

`#include once "mff/UString.bi"`

> [!WARNING]
> Assigning a `WString Ptr` that may be null needs `WGet()`, which is null-safe; dereferencing with a bare `*` will crash on null. This exact mistake was the root cause of the MariaDBBox and SQLite3 build failures - see ControlTesting.md.

### FileListBox

Enumerates the files in a directory, optionally filtered by extension and optionally recursing into subfolders. Set `.Path` and `.Pattern`, then read `.ListCount` and the file entries.

`#include once "mff/FileListBox.bi"`

> [!WARNING]
> **Not a visual control**, despite the name - it has no window and cannot be placed on a form. Pair it with a `ListControl` or `ListView` to display what it finds.

> [!WARNING]
> It declares no `Extends`, so it can never appear in the toolbox.

### FBMemCheck

A memory-leak checking aid for debug builds.

`#include once "mff/FBMemCheck.bi"`

> [!WARNING]
> A diagnostic, not something to ship enabled.

---

## Also present

Types you will meet as part of another control's API rather than on their own: collection
items and column definitions (`ListViewItem`, `ListViewColumn`, `TreeNode`, `GridCell`,
`GridColumn`, `GridRow`, `TreeListViewItem`, `ToolButton`, `StatusPanel`, `ReBarBand`,
`MenuItem`, `ComboBoxItem`, `PaperSize`, `PrintDocumentPage`), plus layout helpers
(`AnchorType`, `MarginsType`, `SizeConstraints`, `ControlCollection`) and the root `Object`
type. These are documented in the framework help under their owning control.

---

## Acknowledgements

Everything described here is the work of the **MyFbFramework** and **VisualFBEditor** authors,
not ours. Astoria has changed none of it - this document exists only because these capabilities
had no discoverable documentation in our tree, not because we wrote them.

With thanks to **Xusinboy Bekchanov**, author of MyFbFramework and VisualFBEditor, and to
**Liu XiaLin**, **Nastase Eodor** and **Aloberoger** for their work across the framework.
MyFbFramework is published under the LGPL / modified LGPL:

- MyFbFramework - <https://github.com/XusinboyBekchanov/MyFbFramework>
- VisualFBEditor - <https://github.com/XusinboyBekchanov/VisualFBEditor>

See [Controls.md](Controls.md#acknowledgements) for the fuller credits, including the bundled
add-on libraries.
