package lysis;

import java.util.LinkedList;
import java.util.List;

// Dice coefficient from http://blog.klaus-b.net/post/2009/10/25/Vergleichen-von-Wortern-mit-dem-Dice-Koeffizienten.aspx
public class Similarity {

    private static List<String> GetTriGrams(String term, boolean useFiller)
    {
        List<String> list = new LinkedList<String>();
        char[] chars = term.toCharArray();
        if (useFiller)
        {
            list.add("__" + chars[0]);
            list.add("_" + chars[0] + chars[1]);
        }
        for (int i = 0; i < chars.length - 2; i++)
        {
            list.add("" + chars[i] + chars[i + 1] + chars[i + 2]);
        }
        if (useFiller)
        {
            list.add("" + chars[chars.length - 2] + chars[chars.length - 1] + "_");
            list.add("" + chars[chars.length - 1] + "__");
        }
        return list;
    }

    public static float GetSimilarity(String first, String second)
    {
        boolean useFiller = first.length() < 5 ? second.length() < 5 : false;
        List<String> firstList = GetTriGrams(first, useFiller);
        List<String> secondList = GetTriGrams(second, useFiller);
        int length = Math.min(firstList.size(), secondList.size());
        int equals = 0;
        for (int i = 0; i < length; i++)
        {
            if (firstList.get(i).equalsIgnoreCase(
                secondList.get(i)))
            {
                equals++;
            }
        }
        return 2 * (float)equals /
                (float)(firstList.size() + secondList.size());
    }
}
