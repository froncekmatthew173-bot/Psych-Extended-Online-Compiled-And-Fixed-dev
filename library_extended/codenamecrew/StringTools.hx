package codenamecrew;

class StringTools
{
    /**
     * Returns true if `s` starts with `start`.
     * Cross‑platform safe implementation.
     */
    public static inline function startsWith(s:String, start:String):Bool
    {
        #if hl
        var slen = s.length;
        var stlen = start.length;
        if (stlen > slen) return false;
        return s.substr(0, stlen) == start;
        #else
        return s.startsWith(start);
        #end
    }

    /**
     * Returns true if `s` ends with `end`.
     * Cross‑platform safe implementation.
     */
    public static inline function endsWith(s:String, end:String):Bool
    {
        #if hl
        var slen = s.length;
        var elen = end.length;
        if (elen > slen) return false;
        return s.substr(slen - elen, elen) == end;
        #else
        return s.endsWith(end);
        #end
    }

    /**
     * Case‑insensitive startsWith.
     */
    public static inline function startsWithCI(s:String, start:String):Bool
    {
        return startsWith(s.toLowerCase(), start.toLowerCase());
    }

    /**
     * Case‑insensitive endsWith.
     */
    public static inline function endsWithCI(s:String, end:String):Bool
    {
        return endsWith(s.toLowerCase(), end.toLowerCase());
    }

    /**
     * Returns true if `s` contains `sub`.
     */
    public static inline function contains(s:String, sub:String):Bool
    {
        return s.indexOf(sub) != -1;
    }

    /**
     * Case‑insensitive contains.
     */
    public static inline function containsCI(s:String, sub:String):Bool
    {
        return s.toLowerCase().indexOf(sub.toLowerCase()) != -1;
    }

    /**
     * Safe replace implementation.
     */
    public static inline function replace(s:String, sub:String, by:String):String
    {
        return s.split(sub).join(by);
    }

    /**
     * Trims whitespace from both ends.
     */
    public static inline function trim(s:String):String
    {
        return s.trim();
    }

    /**
     * Splits a string by a delimiter.
     */
    public static inline function split(s:String, delim:String):Array<String>
    {
        return s.split(delim);
    }

    /**
     * Converts to upper case.
     */
    public static inline function upper(s:String):String
    {
        return s.toUpperCase();
    }

    /**
     * Converts to lower case.
     */
    public static inline function lower(s:String):String
    {
        return s.toLowerCase();
    }

    /**
     * Removes all whitespace.
     */
    public static inline function stripSpaces(s:String):String
    {
        return s.replace(" ", "");
    }

    /**
     * Returns true if the string is empty or null.
     */
    public static inline function isEmpty(s:String):Bool
    {
        return s == null || s.length == 0;
    }

    /**
     * Returns true if the string contains only whitespace.
     */
    public static inline function isBlank(s:String):Bool
    {
        return s == null || s.trim().length == 0;
    }
}
