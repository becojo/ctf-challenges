export default function c() {
  const now = new Date();
  const lat = 45.5017; // America/Montreal
  const lon = -73.5673;

  const start = new Date(now.getFullYear(), 0, 0);
  const dayOfYear = Math.floor((now.getTime() - start.getTime()) / 86400000);

  const latRad = (lat * Math.PI) / 180;
  const zenith = (90.833 * Math.PI) / 180;

  const declination =
    23.45 * Math.sin(((2 * Math.PI) / 365) * (dayOfYear - 81));
  const decRad = (declination * Math.PI) / 180;

  const B = ((2 * Math.PI) / 365) * (dayOfYear - 81);
  const EoT = 9.87 * Math.sin(2 * B) - 7.53 * Math.cos(B) - 1.5 * Math.sin(B);

  const cosHA =
    (Math.cos(zenith) - Math.sin(latRad) * Math.sin(decRad)) /
    (Math.cos(latRad) * Math.cos(decRad));
  const hourAngle = (Math.acos(cosHA) * 180) / Math.PI;

  const solarNoon = 12 - lon / 15 - EoT / 60;
  const sunriseUTC = solarNoon - hourAngle / 15;
  const sunsetUTC = solarNoon + hourAngle / 15;

  function utcHoursToISO(hours: number): string {
    const totalMinutes = Math.round(hours * 60);
    const d = new Date(
      Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()),
    );
    d.setUTCMinutes(totalMinutes);
    return d.toISOString();
  }

  const sunrise = utcHoursToISO(sunriseUTC);
  const sunset = utcHoursToISO(sunsetUTC);

  function utcToEastern(isoString: string): string {
    return new Date(isoString).toLocaleString("en-US", {
      timeZone: "America/Montreal",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: true,
    });
  }

  const sunriseEastern = utcToEastern(sunrise);
  const sunsetEastern = utcToEastern(sunset);

  return {
    sunrise: sunriseEastern,
    sunset: sunsetEastern
};
}
