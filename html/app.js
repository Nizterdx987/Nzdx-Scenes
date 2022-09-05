const { useQuasar } = Quasar
const { ref } = Vue

const app = Vue.createApp({
	setup() {
		const $q = useQuasar()

		const text = ref(null)
		const viewdistance = ref(1)
		const color = ref('#ffffff')
		const fontsize = ref(0.1)
		const fontstyle = ref('1')
		const expiration = ref('1 Jam')

		return {
			text,
			viewdistance,
			color,
			fontsize,
			fontstyle,
			expiration,
			expirationOptions: ['1 Jam', '2 Jam', '4 Jam', '8 Jam', '24 Jam', '48 Jam', '72 Jam'],
			onSubmit() {
				if (color.value === null | viewdistance.value === null | text.value === null | fontsize.value === null) {
					$q.notify({
						color: 'red-5',
						textColor: 'white',
						icon: 'warning',
						message: 'You need to complete all inputs.'
					})
				}
				else {
					const fontTranslation = {
						'1': 0,
						'2': 1,
						'3': 2,
						'4': 4,
						'5': 7,
					}

					SendPostRequest('CreateScene', {
						text: text.value,
						color: color.value,
						viewdistance: viewdistance.value,
						expiration: parseInt(expiration.value.split(' ')[0]),
						fontsize: fontsize.value,
						fontstyle: fontTranslation[fontstyle.value.toString()],
					});
					CloseMenu()
				}
			},
			onDelete() {
				SendPostRequest('DeleteLaser')
				CloseMenu()
			},
			onReset() {
				text.value = null
				color.value = '#ffffff'
				expiration.value = '1 Jam'
				viewdistance.value = 1
				fontsize.value = 0.1
				fontstyle.value = 1
			}
		}
	}
})

app.use(Quasar, { config: {} })
app.mount('#menu')

$(document).ready(function () {
	window.addEventListener("message", function (event) {
		switch (event.data.action) {
			case "open":
				OpenMenu()
				break;
		}
	});

	document.onkeyup = function (data) {
		if (data.key == 'Escape') {
			CloseMenu()
		}
	};
});

function OpenMenu() {
	$("#openmenu").fadeIn();
}

function CloseMenu() {
	$("#openmenu").fadeOut();
	SendPostRequest('CloseMenu')
}

function SendPostRequest(name, data = {}) {
	$.post(`https://${GetParentResourceName()}/${name}`, JSON.stringify(data));
}