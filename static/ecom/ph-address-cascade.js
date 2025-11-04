/* Lightweight PH address cascade using refbrgy.json
 * Populates Region → Province → City/Municipality → Barangay selects
 * Displays names to users while values remain official PSA codes.
 */
(function () {
  async function initPHAddressCascade(cfg) {
    const regionSel = document.getElementById(cfg.region);
    const provinceSel = document.getElementById(cfg.province);
    const citySel = document.getElementById(cfg.citymun);
    const brgySel = document.getElementById(cfg.barangay);
    if (!regionSel || !provinceSel || !citySel || !brgySel) return;

    const url = (cfg.staticPath || '') + 'refbrgy.json';
    const data = await fetch(url).then(r => r.json());

    // Build maps
    const regions = new Map(); // reg_code -> reg_name
    const provincesByRegion = new Map(); // reg_code -> Map(prov_code -> prov_name)
    const citiesByProvince = new Map(); // prov_code -> Map(city_code -> city_name)
    const brgysByCity = new Map(); // city_code -> Map(brgy_code -> brgy_name)

    data.forEach(it => {
      const rc = it.reg_code, rn = it.reg_name;
      const pc = it.prov_code, pn = it.prov_name;
      const cc = it.citymun_code, cn = it.citymun_name;
      const bc = it.brgy_code, bn = it.brgy_name;

      if (!regions.has(rc)) regions.set(rc, rn);
      if (!provincesByRegion.has(rc)) provincesByRegion.set(rc, new Map());
      const provs = provincesByRegion.get(rc);
      if (!provs.has(pc)) provs.set(pc, pn);

      if (!citiesByProvince.has(pc)) citiesByProvince.set(pc, new Map());
      const cities = citiesByProvince.get(pc);
      if (!cities.has(cc)) cities.set(cc, cn);

      if (!brgysByCity.has(cc)) brgysByCity.set(cc, new Map());
      const brgys = brgysByCity.get(cc);
      if (!brgys.has(bc)) brgys.set(bc, bn);
    });

    // Helpers
    function clearAndFill(selectEl, map, placeholder) {
      selectEl.innerHTML = '';
      const ph = document.createElement('option');
      ph.value = '';
      ph.textContent = placeholder;
      selectEl.appendChild(ph);
      for (const [code, name] of map) {
        const opt = document.createElement('option');
        opt.value = code; // submit PSA code
        opt.textContent = name; // show human-readable name
        selectEl.appendChild(opt);
      }
    }

    const aliasToRegCode = {
      'NCR': '130000000', 'CAR': '140000000', 'R1': '010000000', 'R2': '020000000', 'R3': '030000000',
      'R4A': '040000000', 'R4B': '170000000', 'R5': '050000000', 'R6': '060000000', 'R7': '070000000',
      'R8': '080000000', 'R9': '090000000', 'R10': '100000000', 'R11': '110000000', 'R12': '120000000',
      'R13': '160000000', 'BARMM': '150000000'
    };

    function normalizeRegion(val) {
      if (!val) return '';
      return aliasToRegCode[val] || val; // accept alias or PSA code
    }

    const initial = {
      region: normalizeRegion(window.initialRegion || ''),
      province: String(window.initialProvince || ''),
      citymun: String(window.initialCitymun || ''),
      barangay: String(window.initialBarangay || '')
    };

    // Populate Region
    clearAndFill(regionSel, regions, 'Select Region');
    if (initial.region) regionSel.value = initial.region;

    function onRegionChange() {
      const regCode = regionSel.value;
      const provs = provincesByRegion.get(regCode) || new Map();
      clearAndFill(provinceSel, provs, 'Select Province');
      provinceSel.dispatchEvent(new Event('change'));
    }

    function onProvinceChange() {
      const provCode = provinceSel.value;
      const cities = citiesByProvince.get(provCode) || new Map();
      clearAndFill(citySel, cities, 'Select City/Municipality');
      citySel.dispatchEvent(new Event('change'));
    }

    function onCityChange() {
      const cityCode = citySel.value;
      const brgys = brgysByCity.get(cityCode) || new Map();
      clearAndFill(brgySel, brgys, 'Select Barangay');
      if (initial.barangay) brgySel.value = initial.barangay;
    }

    regionSel.addEventListener('change', onRegionChange);
    provinceSel.addEventListener('change', onProvinceChange);
    citySel.addEventListener('change', onCityChange);

    // Trigger cascade and apply initial selections
    onRegionChange();
    if (initial.province) provinceSel.value = initial.province;
    onProvinceChange();
    if (initial.citymun) citySel.value = initial.citymun;
    onCityChange();

    // Keep region short alias in hidden input for backend compatibility if needed
    if (cfg.hiddenRegionAliasInputId) {
      const hidden = document.getElementById(cfg.hiddenRegionAliasInputId);
      regionSel.addEventListener('change', function () {
        const code = regionSel.value;
        // inverse lookup: code -> alias (best-effort)
        const alias = Object.entries(aliasToRegCode).find(([a, c]) => c === code)?.[0] || code;
        if (hidden) hidden.value = alias;
      });
      // initialize once
      const initialAlias = Object.entries(aliasToRegCode).find(([a, c]) => c === regionSel.value)?.[0] || regionSel.value;
      if (hidden) hidden.value = initialAlias;
    }
  }

  window.initPHAddressCascade = initPHAddressCascade;
})();

