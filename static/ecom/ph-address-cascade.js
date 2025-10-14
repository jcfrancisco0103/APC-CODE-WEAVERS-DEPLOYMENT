// ph-address-cascade.js
// Dynamically populates Region, Province, City/Municipality, and Barangay dropdowns using local PSGC JSON files

(function() {
  function qs(id) { return document.getElementById(id); }
  function clearSelect(sel, placeholder) {
    if (!sel) return;
    sel.innerHTML = '';
    const opt = document.createElement('option');
    opt.value = '';
    opt.textContent = placeholder || 'Select';
    sel.appendChild(opt);
  }
  function setPlaceholder(sel, placeholder) {
    if (!sel) return;
    sel.options[0].textContent = placeholder || 'Select';
  }

  async function fetchJSON(url) {
    const res = await fetch(url, { credentials: 'same-origin' });
    if (!res.ok) throw new Error('Network error ' + res.status);
    return res.json();
  }

  window.initPHAddressCascade = function(config) {
    const regionSel = qs(config.region);
    const provinceSel = qs(config.province);
    const citymunSel = qs(config.citymun);
    const barangaySel = qs(config.barangay);
    const staticPath = config.staticPath || '/static/ecom/';

    let regions = [], provinces = [], citymuns = [], barangays = [];

    clearSelect(regionSel, 'Loading Regions...');
    clearSelect(provinceSel, 'Select Province');
    clearSelect(citymunSel, 'Select City/Municipality');
    clearSelect(barangaySel, 'Select Barangay');

    Promise.all([
      fetchJSON(staticPath + 'refregion.json'),
      fetchJSON(staticPath + 'refprovince.json'),
      fetchJSON(staticPath + 'refcitymun.json'),
      fetchJSON(staticPath + 'refbrgy.json')
    ]).then(function([regionData, provinceData, citymunData, brgyData]) {
      regions = regionData.RECORDS || regionData;
      provinces = provinceData.RECORDS || provinceData;
      citymuns = citymunData.RECORDS || citymunData;
      barangays = brgyData.RECORDS || brgyData;

      // Populate regions
      clearSelect(regionSel, 'Select Region');
      regions.forEach(function(region) {
        const opt = document.createElement('option');
        opt.value = region.regCode;
        opt.textContent = region.regDesc;
        regionSel.appendChild(opt);
      });

      // Bind change events
      regionSel && regionSel.addEventListener('change', function() {
        const regCode = regionSel.value;
        clearSelect(provinceSel, 'Select Province');
        clearSelect(citymunSel, 'Select City/Municipality');
        clearSelect(barangaySel, 'Select Barangay');
        if (!regCode) return;
        provinces.filter(p => String(p.regCode) === String(regCode)).forEach(function(province) {
          const opt = document.createElement('option');
          opt.value = province.provCode;
          opt.textContent = province.provDesc;
          provinceSel.appendChild(opt);
        });
      });

      provinceSel && provinceSel.addEventListener('change', function() {
        const provCode = provinceSel.value;
        clearSelect(citymunSel, 'Select City/Municipality');
        clearSelect(barangaySel, 'Select Barangay');
        if (!provCode) return;
        citymuns.filter(c => String(c.provCode) === String(provCode)).forEach(function(city) {
          const opt = document.createElement('option');
          opt.value = city.citymunCode;
          opt.textContent = city.citymunDesc;
          citymunSel.appendChild(opt);
        });
      });

      citymunSel && citymunSel.addEventListener('change', function() {
        const citymunCode = citymunSel.value;
        clearSelect(barangaySel, 'Select Barangay');
        if (!citymunCode) return;
        barangays.filter(b => String(b.citymunCode) === String(citymunCode)).forEach(function(brgy) {
          const opt = document.createElement('option');
          opt.value = brgy.brgyCode;
          opt.textContent = brgy.brgyDesc;
          barangaySel.appendChild(opt);
        });
      });
    }).catch(function(err) {
      // If local JSON fails, leave placeholders so the user sees the selects
      setPlaceholder(regionSel, 'Regions unavailable');
      setPlaceholder(provinceSel, 'Provinces unavailable');
      setPlaceholder(citymunSel, 'Cities unavailable');
      setPlaceholder(barangaySel, 'Barangays unavailable');
      console.error('PH Address cascade failed to load JSON:', err);
    });
  };
})();