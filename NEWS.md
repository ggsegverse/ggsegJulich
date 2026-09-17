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
* The subcortical geometry is polished in two passes. The grey brain
  outline is simplified only as far as leaves its contour rings intact -
  113 of them, 60 of which are interior, where a single pass over the whole
  atlas left 99 and closed ventricles, temporal horns and sulcal fragments
  along with them - and smoothed with Chaikin's corner cutting. The
  structures themselves take a firmer pass and read as smooth nuclei rather
  than as voxel staircases.
