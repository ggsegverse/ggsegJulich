# ggsegJulich 1.0.0.9001

* Both atlases are rebuilt from source against the fixed `ggseg.extra`
  whole-brain pipeline (`ggseg.extra` 1.9.9.9029, `ggseg.formats`
  0.0.4.9005). Every change below follows from that rebuild.

* The subcortical atlas no longer carries a cortical hemisphere as a
  structure. Julich's `Ch_123_(Basal_Forebrain)_left` has volume index 3,
  which is also FreeSurfer's index for left cortex, so the basal forebrain
  mesh absorbed the whole left hemisphere: 74,440 vertices. The pipeline now
  moves subcortical labels off the brain-outline indices, and the largest
  mesh in the atlas is the right CA1 at 2,120 vertices.

* The lookup table gained a `type` column, so parcels are classified
  anatomically instead of by vertex count. 116 labels that are plainly
  cortex -- Area 45, Area TE 3, the insular, orbitofrontal, frontal
  opercular, intraparietal and Heschl series among them -- move out of the
  subcortical atlas and onto the surface.

* 57 structures the previous build lost are back: all hippocampal subfields
  (CA1-CA3, DG, HATA, and the para-, pre-, pro-, sub- and transsubiculum),
  all four deep cerebellar nuclei (dorsal and ventral dentate, fastigial,
  interposed), the metathalamus (CGL, CGM), the amygdalar LB, MF and VTM
  nuclei, and the entorhinal cortex.

* Region labels are no longer truncated at 28 characters, so structures
  such as `Ch_123_Basal_Forebrain_right` and the frontal opercular areas
  are named in full and stay in `core` rather than being treated as
  context.

* The atlas ships a palette you can see. The Julich release names its
  regions but gives no colours, and the previous lookup table wrote black
  for all 296, so a faithful render was a solid silhouette. The table now
  assigns each structure a hue of its own, with a structure's two sides
  sharing a colour the way FreeSurfer's tables do.

* Both atlases are simplified and smoothed after creation, which the
  pipeline no longer does on its own.

* The grey brain outline behind the subcortical structures keeps its
  detail. It used to be polished like a parcel -- simplified hard and then
  smoothed with a morphological close, which fills anything narrower than
  the smoothing distance -- and came out of that with 32 of its 96 rings.
  The parcels are still simplified and smoothed; the outline is now only
  lightly simplified and never smoothed, and keeps 95 of the 96. The
  subcortical atlas grows from 11,960 to 15,711 vertices.

  The outline still has no sulci, and no polish setting can give it any.
  The whole-brain pipeline builds it from the union of the atlas's own
  cortical labels, and Julich's maximum probability map covers both banks
  of every sulcus, so the silhouette is already solid in the volume.

* The four deep cerebellar nuclei stay in the subcortical atlas. They are
  the only cerebellar content Julich has -- 8 of the 50 subcortical
  labels, 16.8 cm3, and no cerebellar cortex, vermis or lobules -- so
  there is no cerebellar parcellation to split off, and
  `create_cerebellar_from_volume()` samples the SUIT cortical flatmap,
  which deep nuclei do not reach.

# ggsegJulich 1.0.0

* First release.
