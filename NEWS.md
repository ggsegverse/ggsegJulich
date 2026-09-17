# ggsegJulich 1.0.0.9001

* The shipped atlases are checked against the source release's own label
  list, so a build that quietly drops regions fails the tests rather than
  reaching users. `data-raw/make_atlas.R` writes that list to
  `tests/testthat/source-labels.txt`: all 294 labels the 2.9 release
  parcellates, less `IF (Amygdala)`, which never wins the maximum
  probability map and so has no voxels to project. The atlases the
  rebuild in 1.0.0.9000 produced carry all 294 (#7).

* The grey brain context in `julich_subcortical()` is simplified harder,
  for a smoother read: `keep = 0.5` and `smoothness = 0.35` rather than
  `keep = 0.85` and `smoothness = 0.25`. The cost is contour rings. The
  unsimplified ribbon has 122 rings, 64 of them interior; `keep = 0.85`
  kept 113 and 60, and `keep = 0.5` keeps 92 and 51. The rings that go
  are small gyral crowns and sulcal fragments, deleted outright rather
  than simplified. The context is a silhouette to read structures
  against rather than an anatomical claim, and the smoother outline was
  judged to read better. Anyone changing this again is trading rings for
  smoothness in one direction or the other. The structures' own pass is
  unchanged.

# ggsegJulich 1.0.0.9000

* Regions are split between the two atlases by anatomy rather than by how
  much surface they cover. The previous build's lookup table had no usable
  `type` column, so the pipeline fell back to counting surface vertices and
  filed roughly 130 cortical parcels - the insular, orbitofrontal and
  parietal series among them - as subcortical. `julich_cortical()` now
  holds 125 regions over 252 rows and `julich_subcortical()` 22 over 44.
* The eight deep cerebellar nuclei (dorsal and ventral dentate, interposed
  and fastigial, both sides) are in `julich_subcortical()`, where they read
  as nuclei. They are anatomically cerebellar, but a ggsegverse cerebellar
  atlas is a SUIT flatmap of the cerebellar cortical sheet and these nuclei
  sit in the cerebellar white matter. Previous builds dropped them.
* `Area Id5 (Insula)` and `Ch 123 (Basal Forebrain)` were classified one
  way on the left and the other on the right, which put each structure in
  both atlases. Both are now whole, the insular area in cortex and the
  basal forebrain nuclei in subcortex.
* `IF (Amygdala)` is the one label of 296 in neither atlas: it never wins
  the maximum probability map, so it has no voxels to draw.
* `Area Fo1 (OFC)` and `Area Fo2 (OFC)` sit on the midline and their
  right-hemisphere labels reach left-hemisphere surface vertices, so each
  has a third row. That is why 125 regions come to 252 rather than 250 rows.
* Both atlases have a real palette again: one hue per structure, shared by
  its two hemispheres, with cortical and subcortical structures drawn from
  the ramp separately.
* The grey brain the subcortical structures are read against is a cortical
  ribbon rather than a solid mantle. Julich's own cortical labels cover both
  banks of every sulcus, so their union held 2.44 times the voxels of a
  ribbon and drew a blob; the silhouette now comes from FreeSurfer's `aseg`,
  where sulcal CSF is unlabelled, so the gyri and sulci are visible. The
  posterior fossa is filled in too, so the cerebellar nuclei are no longer
  drawn against empty space.
* The subcortical geometry is polished in two passes rather than one. The
  grey brain outline is simplified and smoothed with Chaikin's corner
  cutting, which takes off the voxel staircase without fattening the
  ribbon; the structures themselves take a firmer pass with the default
  closing, and read as smooth nuclei rather than as voxel staircases. A
  single pass over the whole atlas left the outline at 99 contour rings
  and closed ventricles, temporal horns and sulcal fragments along with
  them.
