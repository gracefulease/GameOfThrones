var/dmifont/Font1/font = new

dmifont
	var
		name
		height      	// total height of a line
		icon
		defaultWidth 	// width of spaces

	/*	A font's A,B,C widths starting from the first character.
		A	space to add before character
		B	space to add during character (width)
		C	space to add after character	 */
		list/metrics


dmifont
	Font1
		name = "Font1"
		height = 13
		defaultWidth = 5

		metrics = list(\
			list(0, 4, 0),	/* char 30 */ \
			list(0, 4, 0),	/* char 31 */ \
			list(0, 0, 2),	/* char 32 */ \
			list(0, 2, 0),	/* char 33 */ \
			list(0, 3, 0),	/* char 34 */ \
			list(0, 7, 0),	/* char 35 */ \
			list(0, 6, 0),	/* char 36 */ \
			list(0, 7, 0),	/* char 37 */ \
			list(0, 5, 0),	/* char 38 */ \
			list(1, 1, 1),	/* char 39 */ \
			list(0, 3, 0),	/* char 40 */ \
			list(0, 3, 0),	/* char 41 */ \
			list(0, 4, 0),	/* char 42 */ \
			list(0, 4, 0),	/* char 43 */ \
			list(0, 2, 0),	/* char 44 */ \
			list(0, 3, 0),	/* char 45 */ \
			list(0, 2, 0),	/* char 46 */ \
			list(0, 4, 0),	/* char 47 */ \
			list(0, 5, 0),	/* char 48 */ \
			list(0, 4, 0),	/* char 49 */ \
			list(0, 5, 0),	/* char 50 */ \
			list(0, 5, 0),	/* char 51 */ \
			list(0, 5, 0),	/* char 52 */ \
			list(0, 5, 0),	/* char 53 */ \
			list(0, 5, 0),	/* char 54 */ \
			list(0, 5, 0),	/* char 55 */ \
			list(0, 5, 0),	/* char 56 */ \
			list(0, 5, 0),	/* char 57 */ \
			list(0, 2, 0),	/* char 58 */ \
			list(0, 2, 0),	/* char 59 */ \
			list(0, 3, 0),	/* char 60 */ \
			list(0, 4, 0),	/* char 61 */ \
			list(0, 3, 0),	/* char 62 */ \
			list(0, 4, 0),	/* char 63 */ \
			list(0, 8, 0),	/* char 64 */ \
			list(0, 6, 0),	/* char 65 */ \
			list(0, 5, 0),	/* char 66 */ \
			list(0, 5, 0),	/* char 67 */ \
			list(0, 6, 0),	/* char 68 */ \
			list(0, 5, 0),	/* char 69 */ \
			list(0, 5, 0),	/* char 70 */ \
			list(0, 6, 0),	/* char 71 */ \
			list(0, 6, 0),	/* char 72 */ \
			list(0, 4, 0),	/* char 73 */ \
			list(0, 6, 0),	/* char 74 */ \
			list(0, 5, 0),	/* char 75 */ \
			list(0, 4, 0),	/* char 76 */ \
			list(0, 7, 0),	/* char 77 */ \
			list(0, 7, 0),	/* char 78 */ \
			list(0, 7, 0),	/* char 79 */ \
			list(0, 4, 0),	/* char 80 */ \
			list(0, 7, 0),	/* char 81 */ \
			list(0, 5, 0),	/* char 82 */ \
			list(0, 6, 0),	/* char 83 */ \
			list(0, 6, 0),	/* char 84 */ \
			list(0, 6, 0),	/* char 85 */ \
			list(0, 5, 0),	/* char 86 */ \
			list(0, 9, 0),	/* char 87 */ \
			list(0, 6, 0),	/* char 88 */ \
			list(0, 5, 0),	/* char 89 */ \
			list(0, 6, 0),	/* char 90 */ \
			list(0, 3, 0),	/* char 91 */ \
			list(0, 4, 0),	/* char 92 */ \
			list(0, 3, 0),	/* char 93 */ \
			list(0, 5, 0),	/* char 94 */ \
			list(0, 5, 0),	/* char 95 */ \
			list(0, 3, 2),	/* char 96 */ \
			list(0, 4, 0),	/* char 97 */ \
			list(0, 5, 0),	/* char 98 */ \
			list(0, 4, 0),	/* char 99 */ \
			list(0, 5, 0),	/* char 100 */ \
			list(0, 4, 0),	/* char 101 */ \
			list(0, 4, 0),	/* char 102 */ \
			list(0, 4, 0),	/* char 103 */ \
			list(0, 5, 0),	/* char 104 */ \
			list(0, 2, 0),	/* char 105 */ \
			list(0, 3, 0),	/* char 106 */ \
			list(0, 4, 0),	/* char 107 */ \
			list(0, 2, 0),	/* char 108 */ \
			list(0, 7, 0),	/* char 109 */ \
			list(0, 4, 0),	/* char 110 */ \
			list(0, 4, 0),	/* char 111 */ \
			list(0, 4, 0),	/* char 112 */ \
			list(0, 4, 0),	/* char 113 */ \
			list(0, 4, 0),	/* char 114 */ \
			list(0, 4, 0),	/* char 115 */ \
			list(0, 4, 0),	/* char 116 */ \
			list(0, 4, 0),	/* char 117 */ \
			list(0, 4, 0),	/* char 118 */ \
			list(0, 6, 0),	/* char 119 */ \
			list(0, 5, 0),	/* char 120 */ \
			list(0, 4, 0),	/* char 121 */ \
			list(0, 4, 0),	/* char 122 */ \
			list(0, 3, 0),	/* char 123 */ \
			list(1, 1, 1),	/* char 124 */ \
			list(0, 3, 0),	/* char 125 */ \
			list(0, 5, 0),	/* char 126 */ \
			list(0, 4, 0),	/* char 127 */ \
			list(0, 5, 0),	/* char 128 */ \
			list(0, 4, 0),	/* char 129 */ \
			list(0, 2, 0),	/* char 130 */ \
			list(0, 4, -1),	/* char 131 */ \
			list(0, 3, 0),	/* char 132 */ \
			list(0, 6, 0),	/* char 133 */ \
			list(0, 5, 0),	/* char 134 */ \
			list(0, 5, 0),	/* char 135 */ \
			list(0, 5, 0),	/* char 136 */ \
			list(0, 11, 0),	/* char 137 */ \
			list(0, 6, 0),	/* char 138 */ \
			list(0, 3, 0),	/* char 139 */ \
			list(0, 10, 0),	/* char 140 */ \
			list(0, 4, 0),	/* char 141 */ \
			list(0, 6, 0),	/* char 142 */ \
			list(0, 4, 0),	/* char 143 */ \
			list(0, 4, 0),	/* char 144 */ \
			list(0, 1, 0),	/* char 145 */ \
			list(0, 1, 0),	/* char 146 */ \
			list(0, 3, 0),	/* char 147 */ \
			list(0, 3, 0),	/* char 148 */ \
			list(0, 3, 0),	/* char 149 */ \
			list(0, 4, 0),	/* char 150 */ \
			list(0, 7, 0),	/* char 151 */ \
			list(0, 5, 0),	/* char 152 */ \
			list(0, 7, 0),	/* char 153 */ \
			list(0, 4, 0),	/* char 154 */ \
			list(0, 3, 0),	/* char 155 */ \
			list(0, 8, 0),	/* char 156 */ \
			list(0, 4, 0),	/* char 157 */ \
			list(0, 4, 0),	/* char 158 */ \
			list(0, 5, 0),	/* char 159 */ \
			list(0, 0, 2),	/* char 160 */ \
			list(0, 2, 0),	/* char 161 */ \
			list(0, 5, 0),	/* char 162 */ \
			list(0, 7, 0),	/* char 163 */ \
			list(0, 5, 0),	/* char 164 */ \
			list(0, 5, 0),	/* char 165 */ \
			list(1, 1, 1),	/* char 166 */ \
			list(0, 5, 0),	/* char 167 */ \
			list(1, 4, 0),	/* char 168 */ \
			list(0, 7, 0),	/* char 169 */ \
			list(0, 4, 0),	/* char 170 */ \
			list(0, 5, 0),	/* char 171 */ \
			list(0, 4, 0),	/* char 172 */ \
			list(0, 3, 0),	/* char 173 */ \
			list(0, 7, 0),	/* char 174 */ \
			list(0, 5, 0),	/* char 175 */ \
			list(0, 3, 0),	/* char 176 */ \
			list(0, 4, 0),	/* char 177 */ \
			list(1, 3, 1),	/* char 178 */ \
			list(1, 3, 1),	/* char 179 */ \
			list(0, 3, 2),	/* char 180 */ \
			list(0, 4, 0),	/* char 181 */ \
			list(0, 6, 0),	/* char 182 */ \
			list(0, 2, 0),	/* char 183 */ \
			list(1, 3, 1),	/* char 184 */ \
			list(1, 3, 1),	/* char 185 */ \
			list(0, 4, 0),	/* char 186 */ \
			list(0, 5, 0),	/* char 187 */ \
			list(0, 5, 0),	/* char 188 */ \
			list(0, 5, 0),	/* char 189 */ \
			list(0, 5, 0),	/* char 190 */ \
			list(0, 4, 0),	/* char 191 */ \
			list(0, 6, 0),	/* char 192 */ \
			list(0, 6, 0),	/* char 193 */ \
			list(0, 6, 0),	/* char 194 */ \
			list(0, 6, 0),	/* char 195 */ \
			list(0, 6, 0),	/* char 196 */ \
			list(0, 6, 0),	/* char 197 */ \
			list(0, 9, 0),	/* char 198 */ \
			list(0, 5, 0),	/* char 199 */ \
			list(0, 5, 0),	/* char 200 */ \
			list(0, 5, 0),	/* char 201 */ \
			list(0, 5, 0),	/* char 202 */ \
			list(0, 5, 0),	/* char 203 */ \
			list(0, 4, 0),	/* char 204 */ \
			list(0, 4, 0),	/* char 205 */ \
			list(0, 4, 0),	/* char 206 */ \
			list(0, 4, 0),	/* char 207 */ \
			list(0, 6, 0),	/* char 208 */ \
			list(0, 7, 0),	/* char 209 */ \
			list(0, 7, 0),	/* char 210 */ \
			list(0, 7, 0),	/* char 211 */ \
			list(0, 7, 0),	/* char 212 */ \
			list(0, 7, 0),	/* char 213 */ \
			list(0, 7, 0),	/* char 214 */ \
			list(0, 4, 0),	/* char 215 */ \
			list(0, 7, 0),	/* char 216 */ \
			list(0, 6, 0),	/* char 217 */ \
			list(0, 6, 0),	/* char 218 */ \
			list(0, 6, 0),	/* char 219 */ \
			list(0, 6, 0),	/* char 220 */ \
			list(0, 5, 0),	/* char 221 */ \
			list(0, 4, 0),	/* char 222 */ \
			list(0, 4, 0),	/* char 223 */ \
			list(0, 4, 0),	/* char 224 */ \
			list(0, 4, 0),	/* char 225 */ \
			list(0, 4, 0),	/* char 226 */ \
			list(0, 4, 0),	/* char 227 */ \
			list(0, 4, 0),	/* char 228 */ \
			list(0, 4, 0),	/* char 229 */ \
			list(0, 8, 0),	/* char 230 */ \
			list(0, 4, 0),	/* char 231 */ \
			list(0, 4, 0),	/* char 232 */ \
			list(0, 4, 0),	/* char 233 */ \
			list(0, 4, 0),	/* char 234 */ \
			list(0, 4, 0),	/* char 235 */ \
			list(0, 2, 0),	/* char 236 */ \
			list(0, 2, 0),	/* char 237 */ \
			list(0, 2, 0),	/* char 238 */ \
			list(0, 2, 0),	/* char 239 */ \
			list(0, 4, 0),	/* char 240 */ \
			list(0, 4, 0),	/* char 241 */ \
			list(0, 4, 0),	/* char 242 */ \
			list(0, 4, 0),	/* char 243 */ \
			list(0, 4, 0),	/* char 244 */ \
			list(0, 4, 0),	/* char 245 */ \
			list(0, 4, 0),	/* char 246 */ \
			list(0, 4, 0),	/* char 247 */ \
			list(0, 4, 0),	/* char 248 */ \
			list(0, 4, 0),	/* char 249 */ \
			list(0, 4, 0),	/* char 250 */ \
			list(0, 4, 0),	/* char 251 */ \
			list(0, 4, 0),	/* char 252 */ \
			list(0, 4, 0),	/* char 253 */ \
			list(0, 4, 0),	/* char 254 */ \
			list(0, 4, 0))	/* char 255 */


	icon = 'Font1.dmi'

