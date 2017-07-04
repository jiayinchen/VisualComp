import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    // First pass: label the pixels and store labels’ equivalences
    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    int currentLabel = 1;
    // TODO!
    labelsEquivalences.add(null);
    for (int y = 0; y < input.height; y++) {
      for (int x = 0; x < input.width; x++) {
        if (input.pixels[y*input.width + x] == color(255)) {//for every white pixel,
          TreeSet<Integer> tmpLabels = new TreeSet<Integer>();

          if (x > 0) {
            if (labels[y*input.width + x - 1] != 0) {
              tmpLabels.add(labels[y*input.width + x - 1]);
            }
          }
          if (y > 0 && x > 0) {
            if (labels[(y-1)*input.width + x - 1] != 0) {
              tmpLabels.add(labels[(y-1)*input.width + x - 1]);
            }
          }
          if (y > 0) {
            if (labels[(y-1)*input.width + x] != 0) {
              tmpLabels.add(labels[(y-1)*input.width + x]);
            }
          }
          if (y > 0 && x < (input.width - 1)) {
            if (labels[(y-1)*input.width + x + 1] != 0) {
              tmpLabels.add(labels[(y-1)*input.width + x + 1]);
            }
          }
          tmpLabels.remove(0);
          if (tmpLabels.size() > 0) {//if near a marked pixel
            labels[y*input.width +x] = tmpLabels.first();
            if (tmpLabels.size() > 1) {  //if there are several labels available
              TreeSet<Integer> newTmp = new TreeSet<Integer>();
              while (tmpLabels.size() != 0) {
                newTmp.addAll(labelsEquivalences.get(tmpLabels.first()));
                tmpLabels.remove(tmpLabels.first());
              }
              TreeSet<Integer> relatedLabels = (TreeSet)newTmp.clone();
              while (relatedLabels.size() != 0) {

                labelsEquivalences.remove((int)relatedLabels.first());
                labelsEquivalences.add(relatedLabels.first(), newTmp);
                relatedLabels.remove(relatedLabels.first());
              }
            }
          } else {//if not connected to other marked pixels yet 
            labels[y*input.width +x] = currentLabel;
            TreeSet ts = new TreeSet<Integer>();
            ts.add(currentLabel);
            labelsEquivalences.add(ts);
            currentLabel++;
          }
        }
      }
    }
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    // TODO!
    int [] numPixels = new int [labelsEquivalences.size()];

    for (int i = 0; i < input.width*input.height; i++) {
      for (int j = 1; j < labelsEquivalences.size(); j++) {
        if (labels[i] > 0) {//for every labeled pixel
          TreeSet<Integer> tmp = labelsEquivalences.get(j);
          if (tmp.contains(labels[i])) {
            labels[i] = tmp.first();
            numPixels[tmp.first()]++;
            break;
          }
        }
      }
    }

    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    // TODO!
    PImage result = createImage(img.width, img.height, RGB);

    if (onlyBiggest) {
      int max = 0;
      int biggest = 0;
      for (int i = 0; i < numPixels.length; i++) {
        if (numPixels[i] > max) {
          max = numPixels[i];
          biggest = i;
        }
      }
      for (int i = 0; i < input.width * input.height; i++) {
        if (labels[i] == biggest) {
          result.pixels[i] = color(255);
        } else {
          result.pixels[i] = color(0);
        }
      }
    } else {//not working
      colorMode(HSB);

      int hueMod = 28;
      for (int i = 0; i < input.width * input.height; i++) {
        if (labels[i] == 0) result.pixels[i] = color(0);
        else result.pixels[i] = color(hueMod*labels[i]%255, 120, 155);
      }
    }

    return result;
  }
}